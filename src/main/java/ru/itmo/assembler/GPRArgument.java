package ru.itmo.assembler;

public class GPRArgument extends InstructionArgument {
    private int register;
    private final int amount;
    private final boolean scalar;

    public GPRArgument(String initialRepresentation) {
        super(initialRepresentation);
        scalar = initialRepresentation.charAt(0) == 's';
        if (initialRepresentation.charAt(1) != '[') {
            register = Integer.parseInt(initialRepresentation.substring(1));
            amount = 1;
        } else {
            int semicolonIndex = initialRepresentation.indexOf(':');
            register = Integer.parseInt(initialRepresentation.substring(2, semicolonIndex));
            amount = Integer.parseInt(initialRepresentation.substring(semicolonIndex + 1, initialRepresentation.length() - 1)) - register + 1;
        }
    }

    public boolean isScalar() {
        return scalar;
    }

    public int getRegister() {
        return register;
    }

    public void setRegister(int register) {
        this.register = register;
    }

    public int getAmount() {
        return amount;
    }

    @Override
    public String toString() {
        String prefix = scalar ? "s" : "v";
        if (amount == 1)
            return prefix + register;
        else
            return prefix + "[" + register + ":" + (register + amount - 1) + "]";
    }
}
