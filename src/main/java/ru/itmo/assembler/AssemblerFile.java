package ru.itmo.assembler;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.List;

public class AssemblerFile {
    private boolean gallium = false;
    private final List<Kernel> kernels = new ArrayList<>();
    private final List<String> allLines = new ArrayList<>();
    private final List<Integer> scalarCounters = new ArrayList<>();
    private final List<Integer> vectorCounters = new ArrayList<>();
    private final List<List<Integer>> otherRegisterCounters = new ArrayList<>();
    private final List<Integer> kernelsOrder = new ArrayList<>();

    public AssemblerFile() {}

    public void parseFile(String path) throws IOException {
        var lines = Files.readAllLines(Path.of(path));
        var curKernel = -1;
        var curLine = 0;
        var curInstruction = 0;
        for (var line : lines) {
            allLines.add(line);
            var l = line.trim();
            if (l.startsWith(".gallium")) {
                gallium = true;
            } else if (l.startsWith(".kernel ")) {
                curKernel++;
                kernels.add(new Kernel(l.substring(8)));
                otherRegisterCounters.add(new ArrayList<>());
            } else if (gallium && l.startsWith(".wavefront_sgpr_count")) {
                kernels.get(curKernel).setScalarRegisters(Integer.parseInt(l.substring(22)));
                scalarCounters.add(curLine);
            } else if (!gallium && l.startsWith(".sgprsnum")) {
                kernels.get(curKernel).setScalarRegisters(Integer.parseInt(l.substring(10)));
                scalarCounters.add(curLine);
            } else if (gallium && l.startsWith(".workitem_vgpr_count")) {
                kernels.get(curKernel).setVectorRegisters(Integer.parseInt(l.substring(21)));
                vectorCounters.add(curLine);
            } else if (!gallium && l.startsWith(".vgprsnum")) {
                kernels.get(curKernel).setVectorRegisters(Integer.parseInt(l.substring(10)));
                vectorCounters.add(curLine);
            } else if (l.contains("gprsnum") || l.contains("pgmrsrc1")) {
                otherRegisterCounters.get(curKernel).add(curLine);
            } else if (l.charAt(0) == '.' && l.charAt(l.length() - 1) == ':') {
                kernels.get(curKernel).addJump(l.substring(0, l.length() - 1), curInstruction);
            } else if (l.startsWith("/*") && curLine > 0) {
                kernels.get(curKernel).addInstruction(line);
                curInstruction++;
            } else if (!l.startsWith(".") && curLine > 0) {
                boolean isKernel = false;
                var kernelName = l.substring(0, l.length() - 1);
                for (int i = 0; i < kernels.size(); i++) {
                    if (kernelName.equals(kernels.get(i).getName())) {
                        isKernel = true;
                        curKernel = i;
                        kernelsOrder.add(curKernel);
                        break;
                    }
                }
                if (isKernel) {
                    curInstruction = 0;
                } else {
                    kernels.get(curKernel).addInstruction(line);
                    curInstruction++;
                }
            }
            curLine++;
        }
    }

    public void writeToFile(String path) throws IOException {
        for (int i = 0; i < kernels.size(); i++) {
            var scalar = kernels.get(i).getAllScalarRegisters();
            var vector = kernels.get(i).getVectorRegisters();

            var scalarLine = allLines.get(scalarCounters.get(i));
            String newScalarLine;
            if (gallium)
                newScalarLine = scalarLine.substring(0, scalarLine.indexOf(".wavefront_sgpr_count") + 22) + scalar;
            else
                newScalarLine = scalarLine.substring(0, scalarLine.indexOf(".sgprsnum") + 10) + scalar;
            allLines.set(scalarCounters.get(i), newScalarLine);
            var vectorLine = allLines.get(vectorCounters.get(i));
            String newVectorLine;
            if (gallium)
                newVectorLine = vectorLine.substring(0, vectorLine.indexOf(".workitem_vgpr_count") + 21) + vector;
            else
                newVectorLine = vectorLine.substring(0, vectorLine.indexOf(".vgprsnum") + 10) + vector;
            allLines.set(vectorCounters.get(i), newVectorLine);

            scalar = (scalar + 7) / 8 * 8;
            vector = (vector + 3) / 4 * 4;
            for (int index: otherRegisterCounters.get(i)) {
                var line = allLines.get(index);
                String newLine;
                if (line.contains("sgprsnum")) {
                    newLine = line.substring(0, line.indexOf("sgprsnum") + 9) + scalar;
                } else if (line.contains("vgprsnum")) {
                    newLine = line.substring(0, line.indexOf("vgprsnum") + 9) + vector;
                } else {
                    var border = line.indexOf("pgmrsrc1") + 11;
                    StringBuilder number = new StringBuilder(line.substring(border));
                    number = new StringBuilder(Integer.toBinaryString(Integer.parseInt(number.toString(), 16)));
                    while (number.length() < 32) number.insert(0, "0");
                    StringBuilder scalarString = new StringBuilder(Integer.toBinaryString(scalar / 8 - 1));
                    while (scalarString.length() < 4) scalarString.insert(0, "0");
                    StringBuilder vectorString = new StringBuilder(Integer.toBinaryString(vector / 4 - 1));
                    while (vectorString.length() < 6) vectorString.insert(0, "0");
                    number = new StringBuilder(number.substring(0, 22) + scalarString + vectorString);
                    number = new StringBuilder(Integer.toHexString(Integer.parseInt(number.toString(), 2)));
                    while (number.length() < 8) number.insert(0, "0");
                    newLine = line.substring(0, border) + number;
                }
                allLines.set(index, newLine);
            }
        }
        if (Files.exists(Path.of(path))) {
            Files.delete(Path.of(path));
        }
        var file = Files.createFile(Path.of(path));
        var curKernel = -1;
        var curLine = 0;
        var curInstruction = 0;
        for (var line : allLines) {
            var l = line.trim();
            if (!l.startsWith(".") && !l.startsWith("/*")) {
                curKernel++;
                curInstruction = 0;
            }
            if (l.startsWith("/*") && curLine > 0) {
                Files.writeString(file, kernels.get(kernelsOrder.get(curKernel)).getInstruction(curInstruction).toString() + "\n", StandardOpenOption.APPEND);
                curInstruction++;
            } else {
                Files.writeString(file, line + "\n", StandardOpenOption.APPEND);
            }
            curLine++;
        }
    }

    public void minimizeKernelRegisters() {
        for (var kernel: kernels) {
            kernel.minimizeRegisters();
        }
    }
}
