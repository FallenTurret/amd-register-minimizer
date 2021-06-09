package ru.itmo.bmc;

import com.microsoft.z3.*;
import ru.itmo.assembler.Kernel;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

public class KernelRegisterFitter {
    private static final int TIMEOUT_FOR_REGISTER_FINDER = 5000;
    private static final int MAX_REGISTERS_WRITE = 16;

    private final Kernel kernel;
    private final boolean scalar;
    private final int registers;
    private final int minRegisters;
    private List<IntExpr> writeRegVars;
    private List<List<IntExpr>> readRegVars;
    private final List<Integer> writeRegs = new ArrayList<>();
    private final List<List<Integer>> readRegs = new ArrayList<>();

    public KernelRegisterFitter(Kernel kernel, boolean scalar, int minRegisters) {
        this.kernel = kernel;
        this.scalar = scalar;
        this.registers = scalar ? kernel.getScalarRegisters() : kernel.getVectorRegisters();
        this.minRegisters = minRegisters;
    }

    private List<List<Integer>> getSolution() {
        List<List<Integer>> res = new ArrayList<>();
        for (int i = 0; i < kernel.getSize(); i++) {
            var readReg = readRegs.get(i);
            var writeReg = writeRegs.get(i);
            if (writeReg != null)
                readReg.add(0, writeReg);
            res.add(readReg);
        }
        return res;
    }

    public List<List<Integer>> boundedModelChecking() {
        int curBound = 0;
        var regContext = new Context();
        allocateRegisterVars(regContext);
        var regSolver = regContext.mkSolver();
        var params = regContext.mkParams();
        params.add("timeout", TIMEOUT_FOR_REGISTER_FINDER);
        regSolver.setParameters(params);
        regSolver.add(getRegisterConstraints(regContext));
        if (impossibleToFindRegisters(regSolver))
            return null;
        while (existsLoopFreePath(++curBound)) {
            while (true) {
                var path = findBreakingPath(curBound);
                if (path == null)
                    break;
                addPath(regContext, regSolver, path);
                if (impossibleToFindRegisters(regSolver))
                    return null;
            }
        }
        return getSolution();
    }

    private boolean impossibleToFindRegisters(Solver solver) {
        var status = solver.check();
        if (status.equals(Status.SATISFIABLE)) {
            writeRegs.clear();
            readRegs.clear();
            var model = solver.getModel();
            for (var write : writeRegVars) {
                if (write == null) {
                    writeRegs.add(null);
                } else {
                    writeRegs.add(Integer.parseInt(model.getConstInterp(write).toString()));
                }
            }
            for (var read : readRegVars) {
                List<Integer> args = new ArrayList<>();
                for (var arg : read) {
                    args.add(Integer.parseInt(model.getConstInterp(arg).toString()));
                }
                readRegs.add(args);
            }
            return false;
        }
        return true;
    }

    private List<Integer> findBreakingPath(int length) {
        try (Context ctx = new Context()) {
            var path = getPathVars(ctx, length);
            var breakingPaths = IntStream.range(1, length + 1)
                    .mapToObj(
                            i -> ctx.mkAnd(
                                    getPathConstraints(ctx, path.subList(0, i)),
                                    ctx.mkNot(getCorrectnessCheck(ctx, path.subList(0, i)))
                            )
                    ).toArray(BoolExpr[]::new);
            var solver = ctx.mkSolver();
            solver.add(ctx.mkOr(breakingPaths));
            var status = solver.check();
            if (status.equals(Status.SATISFIABLE)) {
                var model = solver.getModel();
                for (int i = 0; i < breakingPaths.length; i++) {
                    if (Boolean.parseBoolean(model.eval(breakingPaths[i], false).toString())) {
                        return path.subList(0, i + 1).stream()
                                .map(model::getConstInterp)
                                .map(Expr::toString)
                                .map(Integer::parseInt)
                                .collect(Collectors.toList());
                    }
                }
            }
            assert status.equals(Status.UNSATISFIABLE);
            return null;
        }
    }

    private boolean existsLoopFreePath(int length) {
        try (Context ctx = new Context()) {
            List<IntExpr> path = getPathVars(ctx, length);
            var isPath = getPathConstraints(ctx, path);

            var blocks = kernel.getBlocks();
            List<List<Integer>> blocksForRegister = new ArrayList<>();
            for (int i = 0; i < registers + minRegisters; i++) {
                List<Integer> curBlocks = new ArrayList<>();
                for (int block = 0; block < blocks.size(); block++) {
                    for (int index: blocks.get(block)) {
                        var writeArg = kernel.getInstruction(index).getWriteRegister(scalar);
                        if (writeArg == null)
                            continue;
                        if (i < registers) {
                            if (writeArg.getRegister() <= i && i < writeArg.getRegister() + writeArg.getAmount()) {
                                curBlocks.add(block);
                                break;
                            }
                        } else {
                            var writeMin = writeRegs.get(index);
                            if (writeMin + registers <= i && i < writeMin + writeArg.getAmount() + registers) {
                                curBlocks.add(i);
                                break;
                            }
                        }
                    }
                }
                blocksForRegister.add(curBlocks);
            }

            List<List<List<BoolExpr>>> registerValue = new ArrayList<>();
            for (var curBlocks: blocksForRegister) {
                List<List<BoolExpr>> curRegister = new ArrayList<>();
                for (var curBlock = 0; curBlock < blocks.size(); curBlock++) {
                    if (!curBlocks.contains(curBlock)) {
                        curRegister.add(new ArrayList<>());
                        continue;
                    }
                    var otherBlocks = new ArrayList<>(curBlocks);
                    otherBlocks.remove((Integer) curBlock);
                    List<BoolExpr> checks = new ArrayList<>();
                    var curCond = ctx.mkFalse();
                    for (int i = 0; i < length; i++) {
                        checks.add(curCond);
                        int finalI = i;
                        curCond = ctx.mkOr(
                                ctx.mkAnd(
                                        curCond,
                                        ctx.mkAnd(
                                                otherBlocks.stream()
                                                        .map(b -> ctx.mkNot(ctx.mkEq(path.get(finalI), ctx.mkInt(b))))
                                                        .toArray(BoolExpr[]::new)
                                        )
                                ),
                                ctx.mkEq(path.get(i), ctx.mkInt(curBlock))
                        );
                    }
                    curRegister.add(checks);
                }
                registerValue.add(curRegister);
            }

            List<BoolExpr> difChecks = new ArrayList<>();
            for (int i = 0; i < length; i++) {
                for (int j = i + 1; j < length; j++) {
                    List<BoolExpr> curChecks = new ArrayList<>();
                    curChecks.add(ctx.mkEq(path.get(i), path.get(j)));
                    for (int reg = 0; reg < blocksForRegister.size(); reg++) {
                        List<BoolExpr> regChecks = new ArrayList<>();
                        int finalReg = reg;
                        regChecks.add(
                                ctx.mkAnd(
                                        IntStream.range(0, j)
                                                .mapToObj(
                                                        k -> ctx.mkAnd(
                                                                blocksForRegister.get(finalReg).stream()
                                                                        .map(b -> ctx.mkNot(ctx.mkEq(path.get(k), ctx.mkInt(b))))
                                                                        .toArray(BoolExpr[]::new)
                                                        )
                                                ).toArray(BoolExpr[]::new)
                                )
                        );
                        for (int block = 0; block < blocks.size(); block++) {
                            if (!blocksForRegister.get(reg).contains(block))
                                continue;
                            regChecks.add(
                                    ctx.mkAnd(
                                            registerValue.get(reg).get(block).get(i),
                                            registerValue.get(reg).get(block).get(j)
                                    )
                            );
                        }
                        curChecks.add(ctx.mkOr(regChecks.toArray(new BoolExpr[0])));
                    }
                    difChecks.add(ctx.mkAnd(curChecks.toArray(new BoolExpr[0])));
                }
            }
            var loop = ctx.mkOr(difChecks.toArray(new BoolExpr[0]));

            var solver = ctx.mkSolver();
            solver.add(ctx.mkAnd(isPath, ctx.mkNot(loop)));
            var status = solver.check();
            if (status.equals(Status.SATISFIABLE))
                return true;
            assert status.equals(Status.UNSATISFIABLE);
            return false;
        }
    }

    private List<IntExpr> getPathVars(Context ctx, int length) {
        return IntStream.range(0, length)
                .mapToObj(i -> ctx.mkIntConst("p" + i))
                .collect(Collectors.toList());
    }

    private BoolExpr getPathConstraints(Context ctx, List<IntExpr> path) {
        var initial = ctx.mkEq(path.get(0), ctx.mkInt(0));
        var transitions = ctx.mkAnd(
                IntStream.range(0, path.size() - 1)
                        .mapToObj(j -> getTransitionCheck(ctx, path.get(j), path.get(j + 1)))
                        .toArray(BoolExpr[]::new)
        );
        return ctx.mkAnd(initial, transitions);
    }

    private void allocateRegisterVars(Context ctx) {
        writeRegVars = new ArrayList<>();
        readRegVars = new ArrayList<>();
        for (int i = 0; i < kernel.getSize(); i++) {
            var instruction = kernel.getInstruction(i);
            var write = instruction.getWriteRegister(scalar);
            var read = instruction.getReadRegisters(scalar);

            writeRegVars.add(write == null || write.isScalar() != scalar ? null : ctx.mkIntConst("r" + i));
            List<IntExpr> readRegs = new ArrayList<>();
            for (int j = 0; j < read.size(); j++) {
                readRegs.add(ctx.mkIntConst("r" + i + "_" + j));
            }
            readRegVars.add(readRegs);
        }
    }

    private BoolExpr getRegisterConstraints(Context ctx) {
        List<BoolExpr> registerConstraints = new ArrayList<>();
        for (int i = 0; i < kernel.getSize(); i++) {
            var reg = writeRegVars.get(i);
            if (reg == null)
                continue;
            var arg = kernel.getInstruction(i).getWriteRegister(scalar);
            var segment = ctx.mkAnd(
                    ctx.mkGe(reg, ctx.mkInt(0)),
                    ctx.mkLe(reg, ctx.mkInt(minRegisters - arg.getAmount()))
            );
            if (scalar && arg.getAmount() >= 2) {
                BoolExpr alignment;
                if (arg.getAmount() >= 4) {
                    alignment = ctx.mkEq(ctx.mkMod(reg, ctx.mkInt(4)), ctx.mkInt(0));
                } else {
                    alignment = ctx.mkEq(ctx.mkMod(reg, ctx.mkInt(2)), ctx.mkInt(0));
                }
                registerConstraints.add(ctx.mkAnd(segment, alignment));
            } else {
                registerConstraints.add(segment);
            }
        }
        for (int i = 0; i < kernel.getSize(); i++) {
            var instruction = kernel.getInstruction(i);
            var args = instruction.getReadRegisters(scalar);
            var regs = readRegVars.get(i);
            for (int j = 0; j < args.size(); j++) {
                var arg = args.get(j);
                var reg = regs.get(j);
                var segment = ctx.mkAnd(
                        ctx.mkGe(reg, ctx.mkInt(0)),
                        ctx.mkLe(reg, ctx.mkInt(minRegisters - arg.getAmount()))
                );
                if (scalar && arg.getAmount() >= 2) {
                    BoolExpr alignment;
                    if (arg.getAmount() >= 4) {
                        alignment = ctx.mkEq(ctx.mkMod(reg, ctx.mkInt(4)), ctx.mkInt(0));
                    } else {
                        if (instruction.getInstruction().startsWith("v_")) {
                            alignment = ctx.mkNot(ctx.mkEq(ctx.mkMod(reg, ctx.mkInt(4)), ctx.mkInt(3)));
                        } else {
                            alignment = ctx.mkEq(ctx.mkMod(reg, ctx.mkInt(2)), ctx.mkInt(0));
                        }
                    }
                    registerConstraints.add(ctx.mkAnd(segment, alignment));
                } else {
                    registerConstraints.add(segment);
                }
            }
        }
        return ctx.mkAnd(registerConstraints.toArray(new BoolExpr[0]));
    }

    private void addPath(Context ctx, Solver solver, List<Integer> path) {
        List<BoolExpr> checks = new ArrayList<>();
        var state = new int[registers];
        for (int i = 0; i < registers; i++) {
            state[i] = -1 - i;
        }
        List<Integer> curPath = new ArrayList<>();
        for (int block: path) {
            for (int i : kernel.getBlocks().get(block)) {
                var instruction = kernel.getInstruction(i);
                var args = instruction.getReadRegisters(scalar);
                var argVars = readRegVars.get(i);
                for (int j = 0; j < args.size(); j++) {
                    var arg = args.get(j);
                    var argVar = argVars.get(j);
                    for (int k = 0; k < arg.getAmount(); k++) {
                        int value = state[arg.getRegister() + k];
                        int ii = -1;
                        if (value < 0) {
                            checks.add(ctx.mkEq(argVar, ctx.mkInt(-(value + 1) - k)));
                        } else {
                            ii = value / MAX_REGISTERS_WRITE;
                            int kk = value % MAX_REGISTERS_WRITE;
                            checks.add(
                                    ctx.mkEq(
                                            ctx.mkAdd(writeRegVars.get(ii), ctx.mkInt(kk)),
                                            ctx.mkAdd(argVar, ctx.mkInt(k))
                                    )
                            );
                        }
                        for (int l = curPath.size() - 1; l >= 0; l--) {
                            var index = curPath.get(l);
                            if (index == ii)
                                break;
                            var writeReg = kernel.getInstruction(index).getWriteRegister(scalar);
                            var writeVar = writeRegVars.get(index);
                            if (writeReg != null) {
                                checks.add(
                                        ctx.mkOr(
                                                ctx.mkGt(writeVar, ctx.mkAdd(argVar, ctx.mkInt(k))),
                                                ctx.mkLe(writeVar, ctx.mkAdd(argVar, ctx.mkInt(k - writeReg.getAmount())))
                                        )
                                );
                            }
                        }
                    }
                }

                var writeArg = instruction.getWriteRegister(scalar);
                if (writeArg != null) {
                    for (int k = 0; k < writeArg.getAmount(); k++) {
                        state[writeArg.getRegister() + k] = i * MAX_REGISTERS_WRITE + k;
                    }
                }
                curPath.add(i);
            }
        }
        solver.add(ctx.mkAnd(checks.toArray(new BoolExpr[0])));
    }

    private BoolExpr getTransitionCheck(Context ctx, IntExpr state1, IntExpr state2) {
        List<BoolExpr> transitions = new ArrayList<>();
        var blocks = kernel.getBlocks();
        for (int block = 0; block < blocks.size(); block++) {
            var here = ctx.mkEq(state1, ctx.mkInt(block));
            var next = kernel.nextPossibleBlocks(block);
            transitions.add(
                    ctx.mkAnd(
                            here,
                            ctx.mkOr(next.stream()
                                    .map(j -> ctx.mkEq(state2, ctx.mkInt(j)))
                                    .toArray(BoolExpr[]::new)
                            )
                    )
            );
        }
        return ctx.mkOr(transitions.toArray(new BoolExpr[0]));
    }

    private BoolExpr getCorrectnessCheck(Context ctx, List<IntExpr> path) {
        var blocks = kernel.getBlocks();
        List<List<Integer>> lastWrite = new ArrayList<>();
        for (var instructions: blocks) {
            List<Integer> state = new ArrayList<>();
            for (int i = 0; i < registers + minRegisters; i++) {
                state.add(-1);
            }
            for (int i: instructions) {
                var instruction = kernel.getInstruction(i);
                var writeArg = instruction.getWriteRegister(scalar);
                var writeMin = writeRegs.get(i);
                if (writeArg != null) {
                    for (int k = 0; k < writeArg.getAmount(); k++) {
                        state.set(writeArg.getRegister() + k, i * MAX_REGISTERS_WRITE + k);
                        state.set(writeMin + k + registers, i * MAX_REGISTERS_WRITE + k);
                    }
                }
            }
            lastWrite.add(state);
        }

        List<BoolExpr> allChecks = new ArrayList<>();
        for (int block = 0; block < blocks.size(); block++) {
            var here = ctx.mkEq(path.get(path.size() - 1), ctx.mkInt(block));
            var state = new int[registers + minRegisters];
            Arrays.fill(state, -1);
            List <BoolExpr> checks = new ArrayList<>();
            checks.add(here);
            for (int i: blocks.get(block)) {
                var instruction = kernel.getInstruction(i);
                var readArgs = instruction.getReadRegisters(scalar);
                var readVars = readRegs.get(i);
                for (int j = 0; j < readArgs.size(); j++) {
                    var readArg = readArgs.get(j);
                    var readMin = readVars.get(j);
                    for (int k = 0; k < readArg.getAmount(); k++) {
                        var read1 = readArg.getRegister() + k;
                        var read2 = readMin + k + registers;
                        if (state[read1] != state[read2]) {
                            checks.add(ctx.mkFalse());
                        } else if (state[read1] == -1) {
                            List<Integer> common = new ArrayList<>();
                            List<Integer> individual = new ArrayList<>();
                            for (int b = 0; b < blocks.size(); b++) {
                                int first = lastWrite.get(b).get(read1);
                                int second = lastWrite.get(b).get(read2);
                                if (first == second && first != -1) {
                                    common.add(b);
                                } else if (first != second) {
                                    individual.add(b);
                                }
                            }
                            var formula = ctx.mkFalse();
                            var noIndividual = ctx.mkTrue();
                            for (int index = path.size() - 2; index >= 0; index--) {
                                int finalIndex = index;
                                formula = ctx.mkOr(
                                        formula,
                                        ctx.mkAnd(
                                                noIndividual,
                                                ctx.mkOr(
                                                        common.stream()
                                                                .map(b -> ctx.mkEq(path.get(finalIndex), ctx.mkInt(b)))
                                                                .toArray(BoolExpr[]::new)
                                                )
                                        )
                                );
                                noIndividual = ctx.mkAnd(
                                        noIndividual,
                                        ctx.mkAnd(
                                                individual.stream()
                                                        .map(b -> ctx.mkNot(ctx.mkEq(path.get(finalIndex), ctx.mkInt(b))))
                                                        .toArray(BoolExpr[]::new)
                                        )
                                );
                            }
                            if (read1 + registers == read2) {
                                formula = ctx.mkOr(
                                        formula,
                                        noIndividual
                                );
                            }
                            checks.add(formula);
                        }
                    }
                }

                var writeArg = instruction.getWriteRegister(scalar);
                var writeMin = writeRegs.get(i);
                if (writeArg != null) {
                    for (int k = 0; k < writeArg.getAmount(); k++) {
                        state[writeArg.getRegister() + k] = state[writeMin + k + registers] = i * MAX_REGISTERS_WRITE + k;
                    }
                }
            }
            allChecks.add(ctx.mkAnd(checks.toArray(new BoolExpr[0])));
        }
        return ctx.mkOr(allChecks.toArray(new BoolExpr[0]));
    }
}
