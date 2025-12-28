package util;

import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Base64;
import java.util.Locale;
import java.util.Objects;

import vetcare.Configura;

/**
 * Lida com a formatação e conversão de dados entre Strings e tipos Java (Datas, BigDecimal).
 * Utiliza a API java.time (thread-safe) para lidar com datas.
 */
final public class DataFormatter {
    
    final static private String IN_FORMAT_STRING = "d/M/yyyy";
    final static private String OUT_FORMAT_STRING = "EEE dd MMM yyyy";

    // Formatters thread-safe de java.time
    final static private DateTimeFormatter IN_FORMATTER = 
        DateTimeFormatter.ofPattern(IN_FORMAT_STRING);
    
    // Usar Locale para que os dias da semana sejam em Português
    final static private DateTimeFormatter OUT_FORMATTER = 
        DateTimeFormatter.ofPattern(OUT_FORMAT_STRING, new Locale("pt", "PT")); 

    /**
     * Retorna o formato de escrita da data fornecida pelo utilizador.
     */
    public static String getInFormato() {
        return IN_FORMAT_STRING;
    }

    /**
     * Retorna o formato de escrita da data no ecrã.
     */
    public static String getDateFormat() {
        return OUT_FORMAT_STRING;
    }

    /**
     * Formata a nota do aluno.
     * @return a nota formatada com dois dígitos inteiros e dois decimais.
     */
    public static String NotaToString(BigDecimal nota) {
        if (Objects.isNull(nota)) return "  -  ";
		NumberFormat formatter = new DecimalFormat("00.00");
		return formatter.format(nota);
	}

    /**
	 * Converte uma Data SQL para String no formato de ecrã (thread-safe).
	 * @param data Data SQL
	 * @return String no formato do ecrã
	 */
    public static String DateToString(java.sql.Date data) {
        if (Objects.isNull(data)) return "";
        return data.toLocalDate().format(OUT_FORMATTER);
	}
    
    /**
     * Converte um objeto LocalDate para uma String no formato "dd/MM/aaaa".
     *
     * @param data A data LocalDate a ser formatada.
     * @return A data formatada como String.
     */
    public static String LocalDateToString(LocalDate data) {
        return data.format(OUT_FORMATTER);
    }

    /**
	 * Converte uma String para um objeto Date SQL.
	 * @param data String fornecida pelo utilizador
	 * @return Data SQL
	 * @throws ParseException Se o formato for inválido.
	 */
	public static java.sql.Date StringToSqlDate(String data) throws ParseException {
        try {
            LocalDate localDate = LocalDate.parse(data, IN_FORMATTER);
            return java.sql.Date.valueOf(localDate);
        } catch (DateTimeParseException e) {
            // Manteve a ParseException para não quebrar o código cliente antigo (Consola)
            throw new ParseException("Formato de data inválido: " + e.getMessage(), 0);
        }
	}

    /**
     * Recebe um objeto java.sql.Date e devolve uma String formatada.
     *
     * @param sqlDate A data a ser formatada (java.sql.Date).
     * @return String no formato YYYYMMDD, ou uma String vazia se a data for null.
     */
    public static String sqlDateToString(Date sqlDate) {
        // 1. Verificar se o objeto é nulo para evitar NullPointerException
        if (Objects.isNull(sqlDate)) {
            return ""; 
        }

        // 2. Definir o padrão de formato: 'yyyy' para ano, 'MM' para mês, 'dd' para dia
        SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMdd");

        // 3. Formatar a data e retornar a String
        return formatter.format(sqlDate);
    }
    
    /**
	 * Retorna uma String com a dimensão 'dim' obtido por concatenação de
	 * espaços na String 'str'
	 * 
	 * @param str String original
	 * @param dim Dimensão final
	 * @param ch Character tipicamente ' '
	 * @return String com espaços
	 */
	public static String fill(String str, int dim, String ch) {
		if (str != null)
			while (dim > str.length())
				str = str + ch;
		return str;
	}
	/**
     * Recebe uma letra (como String) e retorna o género correspondente por extenso.
     *
     * @param letra A letra que representa o género (ex: "M", "F", "X").
     * @return Uma String com o género por extenso (ex: "Masculino", "Feminino", "Desconhecido").
     */
    public static String obterGenero(String letra) {
        
        if (letra == null || letra.trim().isEmpty()) {
            return "Inválido (Letra Vazia)";
        }

        // 1. Normalizar a entrada: remover espaços e converter para maiúsculas
        String inputNormalizado = letra.trim().toUpperCase();
        
        // 2. Usar o primeiro caractere normalizado para a decisão
        char primeiraLetra = inputNormalizado.charAt(0);

        switch (primeiraLetra) {
            case 'M':
                return "Masculino";
            case 'F':
                return "Feminino";
            case 'X': 
                return "Desconhecido";
            default:
                return "Não Especificado";
        }
    }
    
    /**
     * Alinha uma string à esquerda, à direita ou ao centro, preenchendo o restante
     * com espaços até atingir a dimensão máxima especificada.
     *
     * @param texto A string a ser alinhada.
     * @param larguraMaxima A largura total que a string deve ocupar.
     * @param alinhamento O tipo de alinhamento desejado ("ESQUERDA", "DIREITA", "CENTRO").
     * @return A string alinhada e preenchida. Se a string for maior que a largura, é truncada.
     */
    private static String padAll(String texto, int larguraMaxima, String alinhamento) {
        if (texto == null) 
            texto = "";
        texto=texto.trim();
        
        // 1. Truncar se a string for maior que a largura máxima
        if (texto.length() > larguraMaxima) {
            return texto.substring(0, larguraMaxima);
        }

        int tamanhoTexto = texto.length();
        int espacosTotais = larguraMaxima - tamanhoTexto;
        
        // 2. Determinar o preenchimento (padding)
        int espacosEsquerda = 0;
        int espacosDireita = 0;
        
        String tipo = alinhamento.toUpperCase();
        
        if (tipo.equals("ESQUERDA")) {
            espacosEsquerda = 0;
            espacosDireita = espacosTotais;
            
        } else if (tipo.equals("DIREITA")) {
            espacosEsquerda = espacosTotais;
            espacosDireita = 0;
            
        } else if (tipo.equals("CENTRO")) {
            // Divide o espaço total, priorizando o preenchimento extra à direita em caso de número ímpar
            espacosEsquerda = espacosTotais / 2;
            espacosDireita = espacosTotais - espacosEsquerda;
            
        } else {
            // Padrão: Alinhamento à Esquerda para valores inválidos
            espacosEsquerda = 0;
            espacosDireita = espacosTotais;
        }

        // 3. Construir a String Final
        String preenchimentoEsquerda = " ".repeat(espacosEsquerda);
        String preenchimentoDireita = " ".repeat(espacosDireita);

        return preenchimentoEsquerda + texto + preenchimentoDireita;
    }
    
    /**
     * Alinha uma string automaticamente ao CENTRO, preenchendo com espaços 
     * até atingir a largura máxima especificada.
     *
     * @param texto A string a ser alinhada.
     * @param larguraMaxima A largura total da saída (coluna).
     * @return A string alinhada ao centro.
     */
    public static String padCenter(String texto, int larguraMaxima) {
        // Chama o método principal alinharString, fixando o alinhamento
        return padAll(texto, larguraMaxima, "CENTRO");
    }
    
    /**
     * Alinha uma string automaticamente à ESQUERDA, 
     * preenchendo espaços até atingir a largura máxima especificada.
     *
     * @param texto A string a ser alinhada.
     * @param larguraMaxima A largura total da saída (coluna).
     * @return A string alinhada ao centro.
     */
    public static String padLeft(String texto, int larguraMaxima) {
        return padAll(texto, larguraMaxima, "ESQUERDA");
    }
    /**
     * Alinha uma string automaticamente à DIREITA, 
     * preenchendo espaços até atingir a largura máxima especificada.
     *
     * @param texto A string a ser alinhada.
     * @param larguraMaxima A largura total da saída (coluna).
     * @return A string alinhada ao centro.
     */
    public static String padRight(String texto, int larguraMaxima) {
        return padAll(texto, larguraMaxima, "DIREITA");
    }

    public static String format(ResultSet rs, int indice, String coluna, int tipo, int size) throws SQLException {
    		int COL_DIM_MAX=1000; // comprimento máximo includio
    		size=size-1;
    	 // Lógica do BLOB
        if (isBlob(tipo)) {
            String displayValue = getBlobHex(rs, indice);
            if(displayValue.length()>COL_DIM_MAX)
            		return displayValue.substring(0,COL_DIM_MAX-3)+"...";
        } else {// lógica das outras colunas tratadas como String
            String value = rs.getString(indice);
            if(value==null)
            		return DataFormatter.padCenter("-",size);
            else
                if(isNumeric(tipo)) 
                		return DataFormatter.padRight(DataFormatter.formatDecimal(value),size-1)+" ";
                else
                		if(isDateOrTime(tipo))
                			return DataFormatter.padCenter(DataFormatter.formatDate(value),size);
                		else
                			if(coluna.compareToIgnoreCase("genero")==0)
                				return DataFormatter.padCenter(DataFormatter.obterGenero(value), size);
                		
            return DataFormatter.padLeft(value,size);
        }
        return "?";
    }
    
    /**
     * Converte uma String de valor decimal obtida de uma base de dados SQL (padrão americano/internacional)
     * para o formato utilizado em Portugal e na Europa, substituindo o ponto decimal ('.') pela vírgula (',').
     * Este método é ideal para adaptação rápida de dados numéricos lidos de SQL 
     * para apresentação ao utilizador em sistemas que utilizam a vírgula como separador decimal.
     *
     * @param sqlDecimalString A String que representa o valor decimal no formato SQL (ex: "123.45").
     * @return Uma String com o valor decimal formatado para o padrão europeu (ex: "123,45").
     * Retorna uma String vazia ("") se a String de entrada for nula ou vazia/em branco.
     */
    public static String formatDecimal(String sqlDecimalString) {
        if (sqlDecimalString == null || sqlDecimalString.trim().isEmpty())
            return "";
        return sqlDecimalString.replace(".",",");
        /*try {
            // 1. Converte a String SQL (usando ponto) para um Double
            NumberFormat usFormat = NumberFormat.getInstance(Locale.US);
            double number = usFormat.parse(sqlDecimalString).doubleValue();
            
            // 2. Formata o Double para o padrão Português (vírgula)
            NumberFormat ptFormat = NumberFormat.getInstance(new Locale("pt", "PT"));
            return ptFormat.format(number); 
            
            
        } catch (ParseException e) {
            // Se a string não for um número válido (ex: "abc.12"), retorna a original ou vazio.
            return ""; 
        }*/
    }
    /**
     * Converte uma string de data/hora (formato ISO SQL) para o formato português.
     * @param sqlDateTimeString A string de data/hora obtida do ResultSet (ex: "2025-11-23 23:55:38.0").
     * @return A string formatada no padrão português (DD/MM/AAAA HH:mm:ss), 
     * ou a string original se a conversão falhar.
     */
    public static String formatDate(String sqlDateTimeString) {
        if (sqlDateTimeString == null || sqlDateTimeString.trim().isEmpty()) {
            return "";
        }
        
        // O formato de saída desejado em Portugal (Data e Hora)
        DateTimeFormatter formatoPortugues = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");

        try {
            // 1. Tentar analisar como um LocalDateTime (TIMESTAMP)
            // O JDBC pode incluir milissegundos (ex: ".0"), por isso usamos o formato padrão ISO 
            // que lida automaticamente com precisão variável.
            LocalDateTime dateTime = LocalDateTime.parse(sqlDateTimeString, DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss[.S][.SS][.SSS]"));
            
            // 2. Formatar para o padrão português
            return dateTime.format(formatoPortugues);
            
        } catch (DateTimeParseException e1) {
            // Se a primeira tentativa falhar (ex: era apenas uma DATE ou tinha formato TIME)
            try {
                // 3. Tentar analisar como LocalDate (apenas DATE)
                java.time.LocalDate date = java.time.LocalDate.parse(sqlDateTimeString);
                
                // 4. Formatar apenas a data
                return date.format(DateTimeFormatter.ofPattern("dd/MM/yyyy"));
                
            } catch (DateTimeParseException e2) {
                // 5. Se tudo falhar, devolve o valor original
                return "#"+sqlDateTimeString;
            }
        }
    }
    // ======================================================================
    // MÉTODOS AUXILIARES DE TIPO
    // ======================================================================
    
    public static boolean isNumeric(int sqlType) {
        return sqlType == Types.TINYINT 	|| sqlType == Types.SMALLINT 	||
               sqlType == Types.INTEGER 	|| sqlType == Types.BIGINT 		||
               sqlType == Types.FLOAT   	|| sqlType == Types.DOUBLE 		||
               sqlType == Types.REAL    	|| sqlType == Types.NUMERIC 		||
               sqlType == Types.DECIMAL 	||
               sqlType == Types.BIT		|| sqlType == Types.BOOLEAN;
    }
    
    /**
     * Verifica se um tipo de dado SQL é um tipo compativel com BLOB.
     *
     * @param sqlType O código do tipo de dado SQL (constante de java.sql.Types).
     * @return true se o tipo for VARBINARY, LONGVARBINARY ou BLOB.
     */
    public static boolean isBlob(int sqlType) {
        return 	sqlType == Types.VARBINARY 		|| 
        		   	sqlType == Types.LONGVARBINARY 	|| 
        			sqlType == Types.BLOB;
    }
    
    /**
     * Verifica se um tipo de dado SQL é um tipo de Data ou Tempo.
     *
     * @param sqlType O código do tipo de dado SQL (constante de java.sql.Types).
     * @return true se o tipo for DATE, TIME, TIMESTAMP ou variantes de hora/data.
     */
    public static boolean isDateOrTime(int sqlType) {
        return sqlType == Types.DATE        || 
               sqlType == Types.TIME        ||
               sqlType == Types.TIMESTAMP   ||
               sqlType == Types.TIME_WITH_TIMEZONE ||
               sqlType == Types.TIMESTAMP_WITH_TIMEZONE;
    }
    
    /**
     * Converte um BLOB (Binary Large Object) lido de um ResultSet numa String codificada em Base64.
     *
     * @param rs O ResultSet contendo os dados.
     * @param columnIndex O índice da coluna (a partir de 1) que contém o BLOB.
     * @return A String Base64 do BLOB, ou null se o BLOB for nulo na base de dados.
     */
    public static String blobToBase64(ResultSet rs, int columnIndex) throws SQLException {
        
        // Obter o InputStream binário do BLOB
        try (InputStream is = rs.getBinaryStream(columnIndex)) {
            
            // Verifica se o BLOB é nulo na base de dados
            if (is == null || rs.wasNull()) {
                return null;
            }

            final int BUFFER_SIZE = 1024; // Buffer menor é suficiente para ler o fluxo
            byte[] buffer = new byte[BUFFER_SIZE];
            
            // Usamos um ByteArrayOutputStream para acumular todos os bytes do InputStream
            java.io.ByteArrayOutputStream baos = new java.io.ByteArrayOutputStream();
            int bytesRead;

            // 1. Ler o fluxo de bytes do BLOB e armazenar no ByteArrayOutputStream
            while ((bytesRead = is.read(buffer)) != -1) {
                baos.write(buffer, 0, bytesRead);
            }

            // 2. Obter o array de bytes completo
            byte[] blobBytes = baos.toByteArray();

            // 3. Codificar o array de bytes para Base64 (usando a API padrão do Java 8+)
            // O encoder Basic é o mais comum para este tipo de conversão.
            return Base64.getEncoder().encodeToString(blobBytes);
            
        } catch (IOException e) {
            // Log do erro, mas não o impede de retornar uma string de erro ou vazia
            e.printStackTrace();
        } 
        return ""; // Retorna string vazia em caso de erro de I/O
    }
    public static String blobToHexString(ResultSet rs, int columnIndex) throws SQLException {
        try (InputStream is = rs.getBinaryStream(columnIndex)) {
            if (is == null || rs.wasNull()) {
                return null;
            }

            final int BUFFER_SIZE = 1024*100;
            byte[] buffer = new byte[BUFFER_SIZE];
            StringBuilder hexString = new StringBuilder();
            int bytesRead;

            while ((bytesRead = is.read(buffer)) != -1) {
                for (int i = 0; i < bytesRead; i++) {
                    // Garante 2 caracteres em maiúsculas (ex: 0F)
                    hexString.append(String.format("%02X", buffer[i]));
                }
            }
            return hexString.toString();
        } catch (IOException e) {
			e.printStackTrace();
		} 
        return "";
    }
    /**
     * 🎨 Converte o conteúdo BLOB (Binary Large Object) lido de um ResultSet
     * para uma string hexadecimal formatada de acordo com as exigências do SGBD
     * (Sistema de Gestão de Base de Dados) em uso (MySQL ou SQL Server).
     *
     * Esta string formatada é ideal para ser usada em comandos SQL de INSERT/UPDATE
     * para reinserir o conteúdo binário, garantindo a portabilidade de dados BLOB.
     *
     * @param rs O ResultSet 📊 do qual os dados estão a ser lidos.
     * @param columnIndex O índice da coluna (baseado em 1) 🔢 que contém o BLOB.
     * @return String formatada para SQL (ex: "UNHEX('...')", "0x..."), ou "NULL" em caso de erro ou valor nulo.
     */
    public static String getBlobHex(ResultSet rs, int columnIndex) {
        // Instancia o objeto de configuração ⚙️ para determinar o SGBD.
        Configura cfg = new Configura();
        String hexValue = null;

        try {
            // Chama o método auxiliar para converter o BLOB em string hexadecimal pura (ex: "FFD8FF...").
            // 🚀 Assume-se que 'blobToHexString' trata da leitura do BLOB e da conversão.
            hexValue = blobToHexString(rs, columnIndex);
            
            // Se a coluna BLOB for NULL na base de dados, o hexValue será NULL.
            if (hexValue != null) {
                
                // Formatar a string hexadecimal consoante o SGBD 🛠️
                
                if (cfg.isMySQL()) {
                    // 🛠️ MySQL: Utiliza a função UNHEX() para converter a string hex para binário.
                    // Ex: UNHEX('FFD8...')
                    return "UNHEX('" + hexValue + "')";
                    
                } else if (cfg.isSQLServer()) {
                    // 🛠️ SQL Server: Utiliza o prefixo '0x' para indicar que a string é hexadecimal.
                    // Ex: 0xFFD8...
                    return "0x" + hexValue;
                    
                } else {
                    // 🛑 SGBD não reconhecido/suportado. Retorna um erro como comentário SQL.
                    System.err.println("❌ ERRO: SGBD desconhecido ao tentar formatar BLOB para SQL.");
                    return "NULL /* ERRO: SGBD Desconhecido ou não suportado para BLOB ❓*/";
                }
            }

        } catch (SQLException e) {
            // 🚨 Captura erros de acesso à base de dados (durante a leitura do BLOB).
            // Regista o erro para diagnóstico e retorna "NULL" literal como fallback seguro.
            System.err.println("❌ ERRO SQL ao processar BLOB na coluna " + columnIndex + ": " + e.getMessage());
        } 
    
    // Se o BLOB for NULL (na BD) ou se ocorrer uma exceção, retorna "NULL" literal para o SQL.
    return "NULL"; 	
    }
}