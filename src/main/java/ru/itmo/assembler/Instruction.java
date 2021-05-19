package ru.itmo.assembler;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

public class Instruction {
    private final String initialRepresentation;
    private final String instruction;
    private final List<InstructionArgument> args = new ArrayList<>();
    private int argsBegin;
    private int argsEnd;
    private int block;

    public Instruction(String initialRepresentation) {
        this.initialRepresentation = initialRepresentation;
        int insBegin = initialRepresentation.indexOf("*/") + 3;
        int insEnd = insBegin;
        while (insEnd < initialRepresentation.length() && initialRepresentation.charAt(insEnd) != ' ')
            insEnd++;
        instruction = initialRepresentation.substring(insBegin, insEnd);
        argsBegin = insEnd;
        while (argsBegin < initialRepresentation.length() && initialRepresentation.charAt(argsBegin) == ' ')
            argsBegin++;
        argsEnd = argsBegin;
        if (argsBegin == initialRepresentation.length())
            return;
        var allArgs = initialRepresentation.substring(argsBegin).split(", ");
        for (int i = 0; i < allArgs.length - 1; i++) {
            addArg(allArgs[i]);
            argsEnd += allArgs[i].length() + 2;
        }
        var lastBegin = argsEnd;
        argsEnd = initialRepresentation.indexOf(" ", lastBegin);
        if (argsEnd == -1)
            argsEnd = initialRepresentation.length();
        addArg(initialRepresentation.substring(lastBegin, argsEnd));
    }

    public String getInstruction() {
        return instruction;
    }

    public List<InstructionArgument> getArgs() {
        return args;
    }

    public InstructionArgument getArg(int index) {
        return args.get(index);
    }

    public GPRArgument getWriteRegister(boolean scalar) {
        if (args.isEmpty() || !(args.get(0) instanceof GPRArgument))
            return null;
        if (firstArgIsReadRegister() || ((GPRArgument) args.get(0)).isScalar() != scalar)
            return null;
        return (GPRArgument) args.get(0);
    }

    public List<GPRArgument> getReadRegisters(boolean scalar) {
        return args.stream()
                .skip(firstArgIsReadRegister() ? 0 : 1)
                .filter(i -> i instanceof GPRArgument)
                .map(i -> (GPRArgument) i)
                .filter(i -> i.isScalar() == scalar)
                .collect(Collectors.toList());
    }

    @Override
    public String toString() {
        return initialRepresentation.substring(0, argsBegin) +
                args.stream().map(InstructionArgument::toString).collect(Collectors.joining(", ")) +
                initialRepresentation.substring(argsEnd);
    }

    private boolean firstArgIsReadRegister() {
        return
                instruction.startsWith("s_cmp_") ||
                instruction.startsWith("s_bitcmp") ||
                instruction.equals("s_setvskip") ||
                instruction.startsWith("s_set_gpr_idx") ||
                instruction.startsWith("s_buffer_store") ||
                instruction.startsWith("s_dcache") ||
                instruction.startsWith("s_scratch_store") ||
                instruction.startsWith("s_store") ||
                instruction.startsWith("v_cmp") ||
                (instruction.startsWith("ds_") && !instruction.contains("rtn")) ||
                instruction.startsWith("buffer_store") ||
                instruction.startsWith("tbuffer_store") ||
                instruction.startsWith("image_store") ||
                instruction.startsWith("flat_store") ||
                instruction.startsWith("global_store") ||
                instruction.startsWith("scratch_store") ||
                instruction.equals("s_cbranch_join") ||
                instruction.equals("s_cbranch_g_fork") ||
                instruction.equals("s_cbranch_i_fork");
    }

    private boolean isGPR(String arg) {
        if (arg.length() < 2)
            return false;
        char first = arg.charAt(0);
        char second = arg.charAt(1);
        return (first == 's' || first == 'v') && (Character.isDigit(second) || second == '[');
    }

    private void addArg(String arg) {
        if (isGPR(arg)) {
            args.add(new GPRArgument(arg));
        } else {
            args.add(new InstructionArgument(arg));
        }
    }

    public int getBlock() {
        return block;
    }

    public void setBlock(int block) {
        this.block = block;
    }
}
