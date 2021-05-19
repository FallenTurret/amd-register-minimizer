package ru.itmo;

import ru.itmo.assembler.AssemblerFile;

import java.io.IOException;

public class Main {
    public static void main(String[] args) throws IOException {
        if (args.length != 2) {
            System.out.println("Two paths should be specified: input file and output file");
            return;
        }
        var assemblerFile = new AssemblerFile();
        assemblerFile.parseFile(args[0]);
        assemblerFile.minimizeKernelRegisters();
        assemblerFile.writeToFile(args[1]);
    }
}
