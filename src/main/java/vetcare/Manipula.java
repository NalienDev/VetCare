package vetcare;


import java.math.BigDecimal;
import java.sql.BatchUpdateException;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.List;
import java.util.Vector;

import util.Console;

/**
 * @author Engº Porfírio Filipe
 * Esta classe é um utilitário fundamental, 
 * age como uma camada de acesso a dados de baixo nível (uma espécie de wrapper JDBC). 
 * O seu principal objetivo é abstrair a gestão da conexão e a execução de comandos SQL.
 */
public class Manipula {
	// Variável de instância para a conexão ativa. (Deve ser gerida externamente)
	private Connection con = null;
	
	// Variável de instância para o objeto Statement ativo.
	private Statement stm = null;
	
	// Variável de instância para o objeto ResultSet ativo.
	private ResultSet res = null;
	
	// Guarda o número de linhas afetadas pela última execução de um comando DML (UPDATE, INSERT, DELETE).
	public int linhasAfetadas = -1;
	// Objeto que detém as configurações para estabelecer a conexão (e.g., URL, driver, credenciais).
	private Configura cfg=null;

	/**
	 * Construtor por omisão que inicializa a configuração internamente.
	 */
	public Manipula() {
		cfg=new Configura();
	}
	
	/**
	 * Construtor que recebe um objeto Configura.
	 * @param cfg Configurações de conexão à base de dados.
	 */	
	public Manipula(Configura cfg) {
		this.cfg=cfg;
	}
	
	/**
	 * Fecha a conexão ativa e todos os recursos JDBC associados (ResultSet e Statement). 
	 * Deve ser invocada sempre que o acesso aos dados termine para libertar recursos do sistema.
	 * Se a conexão não estiver em modo 'AutoCommit', é realizado um COMMIT antes do fecho.
	 * @return true se a desconexão for bem-sucedida, false caso contrário.
	 */
	public boolean desligar() {
		linhasAfetadas = -1;
		try {
			if(res!=null) {
				res.close();
				res=null;
			}
			if (stm != null) {
				stm.close();
				stm = null;
			}
			if (con != null) {
				if(!con.getAutoCommit()) {
					// Efetua o commit se a transação não tiver sido explicitamente submetida
					con.commit(); 
					Console.writeLine("ℹ️ Transação de Base de Dados submetida (COMMIT).");
				}
				con.close();
				con = null;
				Console.writeLine("👋 Conexão com a Base de Dados fechada com sucesso.");
			}
			return true;
		} catch (Exception e) {
			System.err.println("❌ Erro grave ao fechar a conexão ou recursos JDBC: " + e.getMessage());
			return false;
		}
	}

	/**
	 * Tenta executar um conjunto de comandos SQL (DML ou DDL) em modo 'Batch' (lote).
	 * Caso o Driver JDBC não suporte 'Batch', as directivas são executadas uma a uma.
	 * O envio em lote melhora significativamente a performance em operações DML repetitivas.
	 * @param directivas Array de strings com comandos SQL (não pode incluir SELECTs).
	 * @return true se todos os comandos forem executados com sucesso, false caso contrário.
	 */
	public boolean executaBatch(String directivas[]) {
		DatabaseMetaData dbmd;
		boolean ok = false;
		Statement stmt = getDirectiva();
		
		// 1. Verificar suporte a Batch
		try {
			dbmd = getLigacao().getMetaData();
			ok = dbmd.supportsBatchUpdates();
			if (ok)
				stmt.clearBatch(); // Limpa qualquer operação batch anterior
		} catch (SQLException e) {
			e.printStackTrace();
			System.err.println("❌ Erro (SQL Exception): Falha ao consultar os metadados da Base de Dados.");
			System.err.println("   Detalhe: " + e.getMessage());
			System.err.println("   Nota: Assumir-se-á que não existe suporte para a execução em 'Batch'.");
			// Prossegue, 'ok' será false se a exceção impedir a verificação.
		}
		
		// 2. Execução em MODO BATCH (Lote)
		if (ok) {
			Console.writeLine("⚙️ A preparar a execução de " + directivas.length + " directivas em modo 'Batch'...");
			
			// 2.1 Adicionar comandos ao lote
			for (int i = 0; i < directivas.length; i++) {
				try {
					stmt.addBatch(directivas[i]);
				} catch (SQLException e) {
					e.printStackTrace();
					System.err.println("❌ Erro ao adicionar directiva ao lote.");
					System.err.println("   Directiva: " + directivas[i]);
					System.err.println("   Detalhe: " + e.getMessage());
					return false;
				}
			}
			
			// 2.2 Executar o lote e processar os resultados
			try {
				int[] numUpdates = stmt.executeBatch();
				Console.writeLine("✅ Execução do lote concluída. A processar os resultados:");
				
				for (int i = 0; i < numUpdates.length; i++) {
					if (numUpdates[i] == -2)
						Console
						.writeLine("❓ Directiva "
								+ (i + 1) // Contagem humana
								+ ": Número desconhecido de linhas atualizadas.");
					else if (numUpdates[i] == 1)
						Console.writeLine("✅ Directiva " + (i + 1)
								+ ": 1 linha atualizada com sucesso.");
					else
						Console.writeLine("📝 Directiva " + (i + 1) + ": "
								+ numUpdates[i] + " linhas atualizadas com sucesso.");
				}
			} catch (BatchUpdateException e) {
				e.printStackTrace();
				System.err.println("❌ Erro Grave (BatchUpdateException): Falha na execução de uma das directivas do lote.");
				System.err.println("   Detalhe: " + e.getMessage());
				System.err.println("   A transação poderá ter sido revertida.");
				return false;
			} catch (SQLException e) {
				e.printStackTrace();
				System.err.println("❌ Erro Grave (SQL Exception): Falha geral de acesso à Base de Dados.");
				System.err.println("   Detalhe: " + e.getMessage());
				return false;
			}
		} 
		// 3. Execução em MODO SEQUENCIAL (Fallback)
		else {
			System.err.print("⚠️ O Driver JDBC NÃO suporta a execução em 'Batch'. ");
			System.err.println("O processamento será feito executando comandos individuais.");
			
			for (int i = 0; i < directivas.length; i++) {
				try {
					stmt.executeUpdate(directivas[i]);
                    Console.writeLine("➡️ Directiva " + (i + 1) + " de " + directivas.length + " executada com sucesso.");
				} catch (SQLException e) {
					e.printStackTrace();
					System.err.println("❌ Erro na execução da directiva individual.");
					System.err.println("   Directiva: " + directivas[i]);
					System.err.println("   Detalhe: " + e.getMessage());
					return false;
				}
			}
		}
		
		return true;
	}
    
	/**
	 * Retorna uma mensagem relativa ao número de linhas afetadas na execução
	 * da ultima 'executeUpdate'
	 * 
	 * @return mensagem relativa ao número de linhas afetadas
	 */
	public String getAfetadas() {
	    if (linhasAfetadas == -1) {
	        return "⚠️ Nenhuma linha afetada.";
	    } else if (linhasAfetadas == 0) {
	        return "⚠️ 0 linhas afetadas. Nenhuma alteração efetuada.";
	    } else if (linhasAfetadas == 1) {
	        // Sucesso unitário
	        return "✅ 1 linha afetada com sucesso.";
	    }
	    // Sucesso em lote/múltiplas linhas
	    return "📝 " + linhasAfetadas + " linhas afetadas com sucesso."; 
	}

	/**
	 * Retorna a instrução JDBC (Statement) para executar comandos SQL.
	 * Cria um novo Statement se o atual for nulo.
	 * @return O Statement ativo.
	 */
	public Statement getDirectiva() {
		try {
			if (stm == null) {
				if (con == null)
					getLigacao();
				stm = con.createStatement();
			}
		} catch (SQLException e) {
			System.err.println("❌ Erro na criação da directiva (Statement): " + e.getMessage());
			stm = null;
		}
		return stm;
	}

	/* The  ResultSet can move forward and backward direction by passing either 
	  	TYPE_SCROLL_INSENSITIVE or TYPE_SCROLL_SENSITIVE 
	   in createStatement(int,int) method as well as we can make this object as updatable by:
	    
	    Statement stmt = con.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE,  
	                      					 ResultSet.CONCUR_UPDATABLE);
	    https://www.javatpoint.com/ResultSet-interface                  					 
	    	    
	    Connection.TRANSACTION_READ_UNCOMMITTED (ANSI level 0)	UR, DIRTY READ, READ UNCOMMITTED
		Connection.TRANSACTION_READ_COMMITTED (ANSI level 1)	CS, CURSOR STABILITY, READ COMMITTED
		Connection.TRANSACTION_REPEATABLE_READ (ANSI level 2)	RS
		Connection.TRANSACTION_SERIALIZABLE (ANSI level 3)		RR, REPEATABLE READ, SERIALIZABLE
		https://docs.oracle.com/javadb/10.8.3.0/devguide/cdevconcepts15366.html
	    
	 */
		            	
	/**
	 * Retorna a conexão com a Base de Dados. 
	 * Se a conexão não existir ou estiver fechada,
	 * utiliza o objeto Configura para estabelecê-la novamente.
	 * @return A conexão ativa (Connection).
	 */
	public Connection getLigacao() {
		try {
			if (con == null || con.isClosed()) 
				con = cfg.getConnection();
		} catch (SQLException e) {
			System.err.println("❌ Erro na obtenção/verificação da ligação à BD: " + e.getMessage());
			desligar();
		}
		return con;
	}

	/**
	 * Executa um SELECT (interrogação) e retorna o resultado (ResultSet).
	 * O recurso anterior (ResultSet) é fechado antes de uma nova execução.
	 * @param interroga Query SQL SELECT a ser executada.
	 * @return O ResultSet com os dados, ou null em caso de erro na execução.
	 */
	public ResultSet getResultado(String interroga) {
		try {
			if (res != null) {
				res.close();
				res = null;
			}
			if (getDirectiva() != null) {
				res = stm.executeQuery(interroga);
			}
		} catch (Exception e) {
			System.err.println("❌ Erro ao executar a consulta (SELECT): " + e.getMessage());
			return null;
		}
		return res;
	}

	/**
	 * Executa uma query SELECT e retorna o primeiro objeto 
	 * presente na primeira linha e primeira coluna do ResultSet.
	 * @param directiva SQL SELECT
	 * @return O objeto java presente no 'ResulSet', ou null se não houver resultados.
	 * @throws SQLException Se ocorrer um erro de acesso à BD.
	 */
	public Object getVObject(String directiva) throws SQLException {
		getResultado(directiva);
		if (res!=null && res.next())
			return res.getObject(1);
		return null;
	}

	/**
	 * Executa uma query SELECT e retorna a primeira String 
	 * presente na primeira linha e primeira coluna do ResultSet.
	 * @param directiva SQL SELECT
	 * @return A String presente no 'ResulSet', ou null se não houver resultados.
	 * @throws SQLException Se ocorrer um erro de acesso à BD.
	 */
	public String getVString(String directiva) throws SQLException {
		getResultado(directiva);
		if (res!=null && res.next())
			return res.getString(1);
		return null;
	}

	/**
	 * Executa uma query SELECT e retorna a data SQL (java.sql.Date) 
	 * presente na primeira linha e primeira coluna do ResultSet.
	 * @param directiva SQL SELECT
	 * @return A data SQL presente no 'ResulSet', ou null se não houver resultados.
	 * @throws SQLException Se ocorrer um erro de acesso à BD.
	 */
	public java.sql.Date getVDate(String directiva) throws SQLException {
		getResultado(directiva);
		if (res!=null && res.next())
			return res.getDate(1);
		return null;
	}

	/**
	 * Executa uma query SELECT e retorna o valor numérico (BigDecimal) 
	 * presente na primeira linha e primeira coluna do ResultSet.
	 * @param directiva SQL SELECT
	 * @return O valor numérico presente no 'ResulSet', ou null se não houver resultados.
	 * @throws SQLException Se ocorrer um erro de acesso à BD.
	 */
	public BigDecimal getVBigDecimal(String directiva) throws SQLException {
		getResultado(directiva);
		if (res!=null && res.next())
			return res.getBigDecimal(1);
		return null;
	}

	/**
	 * Executa uma query SELECT e retorna, num Vector de Objetos, 
	 * a primeira linha do ResultSet .
	 * @param directiva SQL SELECT
	 * @return O Vector dos elementos presentes na primeira linha do 'ResulSet', ou um Vector vazio.
	 * @throws SQLException Se ocorrer um erro de acesso à BD.
	 */
	public Vector<Object> getLVector(String directiva) throws SQLException {
		getResultado(directiva);
		ResultSetMetaData rsmd = res.getMetaData();
		int cols = rsmd.getColumnCount();
		Vector<Object> linha = new Vector<Object>(cols);
		if (res!=null && res.next())
			for (int i = 1; i <= cols; i++) {
				linha.add(res.getObject(i));
			}
		return linha;
	}

	/**
	 * Executa uma query SELECT e retorna, num Vector de Objetos, os elementos 
	 * presentes na primeira coluna e em todas as linhas do ResultSet, .
	 * @param directiva SQL SELECT
	 * @return O Vector dos elementos presentes na primeira coluna do 'ResulSet'.
	 * @throws SQLException Se ocorrer um erro de acesso à BD.
	 */
	public Vector<Object> getCVector(String directiva) throws SQLException {
		getResultado(directiva);
		ResultSetMetaData rsmd = res.getMetaData();
		int cols = rsmd.getColumnCount();
		Vector<Object> coluna = new Vector<Object>(cols);
		while (res!=null && res.next())
			coluna.add(res.getObject(1));
		return coluna;
	}

	/**
	 * Devolve true se na sequência da execucão 'executeUpdate' alguma linha foi afectada. 
	 * No caso das instruções SQL DDL (CREATE, ALTER, DROP) devolve sempre false (linhas afetadas é 0).
	 * @return true se foi afectada alguma linha
	 */
	public boolean isUpdated() {
		return linhasAfetadas > 0;
	}

	/**
	 * Executa a directiva indicada em argumento usando a conexão e instrução correntes.
	 * NÃO DEVE SER USADO PARA INSERÇÕES COM INPUT DO UTILIZADOR (risco de SQL Injection).
	 * @param directivaSQL Directiva SQL DML (INSERT, UPDATE, DELETE) ou SQL DDL (CREATE, ALTER, DROP).
	 * @return true se a execução for bem sucedida.
	 */
	public boolean xDirectiva(String directivaSQL) {
		try {
			if (getDirectiva() != null) {
				if (res != null) {
					res.close();
					res = null;
				}
				// Console.writeLine(directivaSQL);
				linhasAfetadas = stm.executeUpdate(directivaSQL);
				Console.writeLine("✅ Execução bem sucedida.");
				Console.writeLine(getAfetadas());
				return true;
			}
			return false;
		} catch (Exception e) {
			System.err.println("SQLState: " +((SQLException)e).getSQLState());
            System.err.println("Error Code: " +((SQLException)e).getErrorCode());
            System.err.println("Message: " + e.getMessage());
			Console.writeLine("❌ Falhou a execução: "+directivaSQL);
			return false;
		}
	}
	/**
	 * Executa uma directiva SQL DML (INSERT, UPDATE, DELETE) de forma SEGURA 
	 * usando PreparedStatement para prevenir SQL Injection.
	 *
	 * @param sqlSegura A directiva SQL com marcadores de posição (?).
	 * @param objParametros Uma lista ordenada de objetos (valores) a serem ligados ao SQL.
	 * @return true se a execução for bem-sucedida.
	 */
	public boolean xDirectiva(String sqlSegura, List<Object> objParametros) {
	    linhasAfetadas = -1;

	    // 1. Obter a Conexão ATIVA (fora do try-with-resources para evitar fecho prematuro)
	    Connection conexao = getLigacao(); 
	    
	    // Verificação de segurança (embora getLigacao() já o faça)
	    if (conexao == null) {
	        System.err.println("❌ Erro: Não foi possível obter uma conexão válida.");
	        return false;
	    }

	    // 2. Usar try-with-resources APENAS para o PreparedStatement
	    try (PreparedStatement preparedStatement = conexao.prepareStatement(sqlSegura)) {
	        
	        // 1. Ligar os parâmetros (?)
	        if (objParametros != null) {
	            int index = 1;
	            for (Object param : objParametros) {
	                
	                // --- INÍCIO DO MAPEAMENTO DE TIPOS (Melhorado) ---
	                
	                if (param == null) {
	                    // Usar Types.NULL ou Types.OTHER. Types.VARCHAR é inadequado.
	                    // Tipicamente, Types.NULL ou Types.OTHER funcionam melhor para null genérico.
	                    preparedStatement.setNull(index, Types.NULL); 
	                    
	                } else if (param instanceof String) {
	                    preparedStatement.setString(index, (String) param);
	                } else if (param instanceof Integer) {
	                    preparedStatement.setInt(index, (Integer) param);
	                } else if (param instanceof Long) {
	                    preparedStatement.setLong(index, (Long) param);
	                } else if (param instanceof Boolean) {
	                    preparedStatement.setBoolean(index, (Boolean) param);
	                } else if (param instanceof BigDecimal) {
	                    preparedStatement.setBigDecimal(index, (BigDecimal) param);
	                } else if (param instanceof java.sql.Date) {
	                    preparedStatement.setDate(index, (java.sql.Date) param);
	                } else if (param instanceof java.util.Date) {
	                    // Conversão para Timestamp para cobrir ambos data e hora de java.util.Date
	                    preparedStatement.setTimestamp(index, new Timestamp(((java.util.Date) param).getTime()));
	                } else if (param instanceof Double) {
	                    preparedStatement.setDouble(index, (Double) param);
	                } else if (param instanceof Float) {
	                    preparedStatement.setFloat(index, (Float) param);
	                } else {
	                    // Fallback: Tenta definir o objeto diretamente.
	                    preparedStatement.setObject(index, param); 
	                }
	                
	                // --- FIM DO MAPEAMENTO DE TIPOS ---
	                
	                index++;
	            }
	        }
	        
	        // 3. Executar e obter o número de linhas afetadas
	        linhasAfetadas = preparedStatement.executeUpdate();
	        
	        // 4. Output de sucesso (usando a lógica de log existente)
	        Console.writeLine("✅ Execução bem sucedida.");
	        Console.writeLine(getAfetadas());
	        return true;
	        
	    } catch (SQLException e) {
	        System.err.println("❌ Erro em xDirectiva: " + e.getMessage());
	        System.err.println("SQLState: " + e.getSQLState());
	        System.err.println("Error Code: " + e.getErrorCode());
	        Console.writeLine("❌ Falhou a execução: "+sqlSegura);
	        return false;
	    }
	}
}