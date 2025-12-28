package util;

import java.io.*;

/**
 * Lida exclusivamente com a leitura e escrita para a Consola (Standard I/O).
 * Implementa a lógica de fechar o I/O.
 */
final public class Console {

    private static final BufferedReader br;
    private static PrintWriter streamOut = null; // Stream opcional para browser/output

    static {
        // Inicialização estática do BufferedReader (Standard Input)
        try {
            br = new BufferedReader(new InputStreamReader(System.in));
        } catch (Exception exp) {
            // Em caso de erro grave no acesso ao Standard Input
            System.err.println("❌ Erro no acesso ao Standard Input.");
            throw new RuntimeException(exp); 
        }
    }

    /**
     * Fecha o BufferedReader para libertar recursos de I/O.
     */
    public static void close() {
        try {
            if (br != null) {
                br.close();
            }
        } catch (IOException e) {
            System.err.println("❌ Erro ao fechar o Standard Input: " + e.getMessage());
        }
    }

    /**
     * Define um stream de output opcional (e.g., para um browser/servlet).
     */
    public static void setOutStream(PrintWriter p) {
        streamOut = p;
    }

    /**
     * Lê uma linha do Standard Input.
     * Trata de forma mais robusta erros de I/O.
     * @return Linha lida (nunca null, retorna "" em caso de erro/fim).
     */
    public static String readLine() {
        String line = null;
        try {
            line = br.readLine();
        } catch (IOException exp) {
            // Log do erro, mas permite à aplicação continuar
            System.err.println("❌ Erro na leitura de uma linha do Standard Input: " + exp.getMessage());
            return ""; // Retorna string vazia para o chamador
        }
        return (line != null) ? line : "";
    }

    /**
     * Lê um caracter do Standard Input, convertendo-o para minúscula.
     * @return Caracter lido, ou ' ' se a linha for vazia.
     */
    public static char readChar() {
        String str = Console.readLine().trim().toLowerCase();
        if (str.length() > 0) {
            return str.charAt(0);
        }
        return ' ';
    }

    /**
     * Escreve uma linha no Standard Output e, opcionalmente, no stream de output.
     * @param line Linha a ser escrita.
     */
    public static void writeLine(String line) {
        if (line != null) {
            System.out.println(line);
            if(streamOut != null) {
                // Utiliza <pre> para manter a formatação da consola no ambiente web
                streamOut.println("<pre>" + line + "</pre>"); 
            }
        }
    }
}