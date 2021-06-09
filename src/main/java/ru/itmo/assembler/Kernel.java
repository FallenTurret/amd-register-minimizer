package ru.itmo.assembler;

import ru.itmo.bmc.KernelRegisterFitter;

import java.util.*;

public class Kernel {
    private final String name;
    private final List<Instruction> instructions = new ArrayList<>();
    private final Map<String, Integer> jumps = new HashMap<>();
    private int scalarRegisters;
    private int extraScalarRegisters = 0;
    private int vectorRegisters;
    private List<List<Integer>> blocks = null;

    public Kernel(String name) {
        this.name = name;
    }

    public void addInstruction(String instruction) {
        instructions.add(new Instruction(instruction));
    }

    public void addJump(String label, int instructionPosition) {
        jumps.put(label, instructionPosition);
    }

    public int getScalarRegisters() {
        return scalarRegisters;
    }

    public int getAllScalarRegisters() {
        return scalarRegisters + extraScalarRegisters;
    }

    public void setScalarRegisters(int scalarRegisters) {
        this.scalarRegisters = scalarRegisters;
    }

    public int getVectorRegisters() {
        return vectorRegisters;
    }

    public void setVectorRegisters(int vectorRegisters) {
        this.vectorRegisters = vectorRegisters;
    }

    public String getName() {
        return name;
    }

    public Instruction getInstruction(int index) {
        return instructions.get(index);
    }

    public int getSize() {
        return instructions.size();
    }

    public List<List<Integer>> getBlocks() {
        if (blocks == null) {
            getBlocksDistribution();
        }
        return blocks;
    }

    private void getBlocksDistribution() {
        var jumpDestinations = jumps.values().toArray(new Integer[0]);
        Arrays.sort(jumpDestinations);
        int j = 0;
        List<Integer> curBlock = new ArrayList<>();
        blocks = new ArrayList<>();
        for (int i = 0; i < getSize(); i++) {
            while (j < jumps.size() && jumpDestinations[j] == i) {
                if (!curBlock.isEmpty()) {
                    blocks.add(curBlock);
                    curBlock = new ArrayList<>();
                }
                j++;
            }
            var instruction = getInstruction(i);
            curBlock.add(i);
            instruction.setBlock(blocks.size());
            if (instruction.getInstruction().contains("branch") || instruction.getInstruction().startsWith("s_endpgm")) {
                blocks.add(curBlock);
                curBlock = new ArrayList<>();
            }
        }
        if (!curBlock.isEmpty()) {
            blocks.add(curBlock);
        }
    }

    public List<Integer> nextPossibleBlocks(int blockIndex) {
        var block = blocks.get(blockIndex);
        var instruction = instructions.get(block.get(block.size() - 1));
        var string = instruction.getInstruction();
        if (string.startsWith("s_endpgm"))
            return List.of();
        if (string.equals("s_branch")) {
            var index = jumps.get(instruction.getArg(0).toString());
            return List.of(getInstruction(index).getBlock());
        }
        if (string.equals("s_cbranch_i_fork")) {
            var index = jumps.get(instruction.getArg(1).toString());
            return List.of(blockIndex + 1, getInstruction(index).getBlock());
        }
        if (string.startsWith("s_cbranch")) {
            var index = jumps.get(instruction.getArg(0).toString());
            return List.of(blockIndex + 1, getInstruction(index).getBlock());
        }
        return List.of(blockIndex + 1);
    }

    public void minimizeRegisters() {
        adjustScalarCounter();
        for (var instruction: instructions) {
            var string = instruction.getInstruction();
            if (
                    string.equals("s_trap") ||
                    string.startsWith("s_rfe") ||
                    string.equals("s_cbranch_g_fork") ||
                    string.startsWith("s_setpc") ||
                    string.startsWith("s_swappc") ||
                    string.equals("s_setvskip") ||
                    string.equals("s_call_b64")
            )
                return;
        }
        minimizeRegisters(false);
        for (var instruction: instructions) {
            var string = instruction.getInstruction();
            if (string.equals("s_cbranch_i_fork") || string.equals("s_cbranch_join"))
                return;
        }
        minimizeRegisters(true);
    }

    private void minimizeRegisters(boolean scalar) {
        int l = -1;
        int r = scalar ? scalarRegisters : vectorRegisters;
        List<List<Integer>> res = null;
        while (r - l > 1) {
            int m = (l + r) / 2;
            var fitter = new KernelRegisterFitter(this, scalar, m);
            var cur = fitter.boundedModelChecking();
            if (cur == null) {
                l = m;
            } else {
                res = cur;
                r = m;
            }
        }
        if (res == null)
            return;
        if (scalar) {
            setScalarRegisters(r);
        } else {
            setVectorRegisters(r);
        }
        for (int i = 0; i < getSize(); i++) {
            var newRegs = res.get(i);
            int j = 0;
            for (var arg: getInstruction(i).getArgs()) {
                if (arg instanceof GPRArgument && ((GPRArgument) arg).isScalar() == scalar) {
                    ((GPRArgument) arg).setRegister(newRegs.get(j++));
                }
            }
        }
    }

    private void adjustScalarCounter() {
        int maxReg = 0;
        for (int i = 0; i < getSize(); i++) {
            for (var arg: getInstruction(i).getArgs()) {
                if (arg instanceof GPRArgument && ((GPRArgument) arg).isScalar()) {
                    maxReg = Integer.max(maxReg, ((GPRArgument) arg).getRegister() + ((GPRArgument) arg).getAmount());
                }
            }
        }
        extraScalarRegisters = scalarRegisters - maxReg;
        scalarRegisters = maxReg;
    }
}
