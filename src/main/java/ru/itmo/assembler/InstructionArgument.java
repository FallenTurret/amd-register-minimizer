package ru.itmo.assembler;

public class InstructionArgument {
    private final String initialRepresentation;

    public InstructionArgument(String initialRepresentation) {
        this.initialRepresentation = initialRepresentation;
    }

    @Override
    public String toString() {
        return initialRepresentation;
    }
}
