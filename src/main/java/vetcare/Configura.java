package vetcare;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.Driver;
import java.sql.DriverManager;
import java.sql.DriverPropertyInfo;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

import util.DataFormatter;

/**
 * Define a configuração usada no acesso à base de dados via JDBC.
 * A configuração de acesso é carregada de um ficheiro externo (db.properties) 
 * para garantir segurança e fácil manutenção.
 * Preparado para o MySQL e para o SQLServer com driver JDBC tipo 1 e tipo 4.
 * 
 * @author Engº Porfírio Filipe
 */

/*
--> Linguagem simplicada do JDBC
	 System.out.println("✅ Conexão estabelecida com sucesso!");
	 System.out.println("🔌 Conexão fechada.");
	 System.err.println("❌ Falha ao estabelecer a conexão.");
     System.out.println("⚙️ A iniciar transação...");
     System.out.println("👍 Transação confirmada (COMMIT).");
     System.err.println("🚨 Erro no SQL. Transação revertida (ROLLBACK).");
     System.out.println("🛠️ Conexão iniciada por omissão.");

*/

public class Configura {
	
	// Enum para selecionar explicitamente o SGBD na instanciação
	public enum SGBD {
		SQLServer, MySQL
	}
	
	// Constante estática para o nome do ficheiro de configuração.
	private static final String CONFIG_FILE = "WEB-INF/db_config.properties";
	
	// --- Variáveis de INSTÂNCIA (Permitem múltiplas configurações) ---
	
	private String database 		= "ga";			// Nome por omissão da Base de Dados
	private String server 	    = "localhost"; 	// Servidor por omissão
	private String usr 		    = "root";		// Utilizador por omissão (deve ser carregado do ficheiro)
	private String pwd 		    = "root";		// Password por omissão (deve ser carregada do ficheiro)
	private String drv		    = null;			// Nome da classe do Driver JDBC específico
	private String url		    = null;			// URL de conexão JDBC específico
	private SGBD   sgbd			= null;			// O SGBD selecionado para esta instância

	// --- Construtor ---

	/**
	 * construtor sem parâmetros que, por omissão, configura a conexão para MySQL.
	 */
	public Configura () {
		// Chama o construtor principal, usando MySQL como o SGBD padrão.
		this(SGBD.MySQL); 
	}
	/**
	 * Cria uma nova instância de Configura para um SGBD específico.
	 * Inicializa o driver e a URL, e carrega as credenciais do ficheiro de propriedades.
	 * @param sgbd O Sistema Gestor de Base de Dados (SGBD.MySQL ou SGBD.SQLServer).
	 */
	public Configura (SGBD sgbd) {
		this.sgbd = sgbd;
		build();
		loadProperties();
		loadDriver();
	}
	
	private synchronized void build() {
			if(this.isSQLServer()) {
				this.drv = "com.microsoft.sqlserver.jdbc.SQLServerDriver";	
				this.url = "jdbc:sqlserver://"+this.server+":1433;databaseName="
				+this.database+";encrypt=true;trustServerCertificate=true;";
			} else if(this.isMySQL()) {
				this.drv = "com.mysql.cj.jdbc.Driver";
				this.url = "jdbc:mysql://" + this.server + ":3306/" + this.database
						+ "?useLegacyDatetimeCode=false&serverTimezone=Europe/Lisbon";
			}
	}
	
	public String getRealPath() {
		String filePath = "src/main/webapp/";
		if(!new File(filePath).exists())
			filePath = getWebRootPath(server);
		return filePath;
	}
	/**
	 * Carrega o ficheiro de propriedades e inicializa os parametros de conexão (servidor, utilizador, password).
	 * Sugestão: Num ambiente de produção, garantir que este método lança uma exceção se o ficheiro falhar.
	 */
	private void loadProperties() {
		String filePath = getRealPath()+CONFIG_FILE;
			
		// System.out.println("💡 Caminho da configuração de acesso:\n'"+filePath+"'");
		Properties properties = new Properties();
		try (FileInputStream fis = new FileInputStream(filePath)) {
			properties.load(fis);
			
			// Atualiza as variáveis de INSTÂNCIA com as credenciais lidas do ficheiro.
			this.server = properties.getProperty("db.server").trim();
			this.usr = properties.getProperty("db.user").trim();
			this.pwd = properties.getProperty("db.password").trim();
			
		} catch (IOException e) {
			System.err.println("❌ Falha ao carregar o ficheiro '"+CONFIG_FILE+"'.");
			// e.printStackTrace();
		}
	}

	/**
	 * Carrega a classe do Driver JDBC para esta instância.
	 * @return true se o driver foi carregado com sucesso, false caso contrário.
	 */
	public boolean loadDriver() {
		try {
			// System.out.println("Vai carregar o driver (" + this.drv + ")...");
			Class.forName(this.drv);
			return true;
		} catch (ClassNotFoundException e) {
			System.err.println("❌ Não é possível carregar o Driver JDBC: " + this.drv + ".");
			System.err.println("Verifique se o JAR do Driver está no classpath.");
			e.printStackTrace();
		} catch (Exception e) {
			System.err.println("🚨 Erro inesperado no carregamento do Driver JDBC: " + this.drv + ".");
			e.printStackTrace();
		}
		return false;
	}

	/**
	 * Apresenta as propriedades do driver corrente.
	 * Sugestão: Este método é útil para diagnóstico, mas deve ser removido ou protegido em produção.
	 */
	public void showDriverProperties() {
		try {
			// Carrega o driver explicitamente, embora já o tenha feito no construtor.
			Class.forName(drv); 

			Driver driver = DriverManager.getDriver(url);

			System.out.println("Vai listar as propriedades do driver...");
			DriverPropertyInfo[] info = driver.getPropertyInfo(url, null);
			for (int i = 0; i < info.length; i++) {
				// Os detalhes são impressos para diagnóstico.
				String name = info[i].name;
				boolean isRequired = info[i].required;
				String value = info[i].value;
				String desc = info[i].description;
				String[] choices = info[i].choices;
				System.out.println(name + " (" + ((isRequired) ? "Obrigatório" : "Opcional") + ") " + ": " + value
						+ ", " + desc + ", " + choices);
			}
		} catch (ClassNotFoundException e) {
			System.err.println("Driver: "+e.getMessage());
		} catch (SQLException e) {
			System.err.println("SQLException" + e.getMessage());
		}
	}

	// --- Métodos de Conexão ---
	
	/**
	 * Devolve uma nova conexão à base de dados com as configurações transacionais por omissão:
	 * - AutoCommit: TRUE
	 * - Nível de Isolamento: TRANSACTION_READ_UNCOMMITTED
	 * @return Objeto Connection ou null em caso de falha.
	 */
	public Connection getConnection() {
		// Por omissão fica em autocommit e com baixo isolamento.
		return getConnection(true, Connection.TRANSACTION_READ_UNCOMMITTED);
	}
	
	/**
	 * Devolve uma nova conexão, tratando a exceção de forma silenciosa (apenas com prints).
	 * Sugestão: Em código de produção, considere ter apenas o getConnection_ e propagar a exceção.
	 */
	public Connection getConnection(boolean autocommit, int level) {
		Connection con=null;
		try {
			con = getConnection_(autocommit, level); // Chama o método que propaga a exceção.
			// System.out.println("✅ Conexão estabelecida com sucesso!");
		} catch (SQLException e) {
			System.err.println("🚨 Falha na Conexão SQL.");
			System.err.println("❌ Não é possivel estabelecer a ligação com a base de dados.");
			System.err.println("Veja a descrição completa do erro:");
			// AVISO: Em aplicações robustas, esta exceção deve ser propagada
			// e.printStackTrace();
		} 
		return con;
	}
	
	/* *
	 * Níveis de Isolamento (ANSI/ISO SQL) e Anomalias:
	 * ------------------------------------------------------------------------------------------------------------------------------------------------
	 * Nível                                  | Descrição                                         | Previne
	 * ------------------------------------------------------------------------------------------------------------------------------------------------
	 * TRANSACTION_READ_UNCOMMITTED (Level 0) | O mais baixo. Permite todas as anomalias.         | Nenhuma
	 * TRANSACTION_READ_COMMITTED   (Level 1) | Previne Leitura Suja (Dirty Read).                | Leitura Suja (Dirty Read)
	 * TRANSACTION_REPEATABLE_READ  (Level 2) | Previne Leitura Suja e Leitura Não Repetível.     | Dirty Read e Non-Repeatable Read
	 * TRANSACTION_SERIALIZABLE     (Level 3) | O mais alto. Previne todas as anomalias.          | Todas, incluindo Leitura Fantasma (Phantom Read)
	 * ------------------------------------------------------------------------------------------------------------------------------------------------
	 */
	/**
	 * ** Propaga a exceção SQL!
	 * Devolve uma nova conexão à base de dados, permitindo a configuração 
     * do modo AutoCommit e do Nível de Isolamento da Transação.
	 * @param autocommit Define o estado do AutoCommit (true/false).
	 * @param level Define o nível de isolamento da transação (constantes Connection.TRANSACTION_...).
	 * @return Objeto Connection.
	 * @throws SQLException Se ocorrer um erro ao estabelecer ou configurar a conexão.
	 */
	private Connection getConnection_(boolean autocommit, int level) throws SQLException {
		Connection con = null;
		// 1. Estabelecer a Conexão (Usa as variáveis de instância)
		con = DriverManager.getConnection(this.url, this.usr, this.pwd);
		// 2. Configurar a Conexão
		con.setAutoCommit(autocommit);
		con.setTransactionIsolation(level);
		return con;
	}
	
	// --- Métodos de Suporte Estáticos ---
	
	/**
     * Faz um acesso HTTP GET ao servlet especificado para obter o caminho real
     * do sistema de ficheiros para a raiz da aplicação (o diretório do .war).
     * @return O caminho obtido do Servlet, ou null se ocorrer um erro.
     */
    public static String getWebRootPath(String server) {
    		String servletURL	="http://"+server+"/GA/WebRootPath";
        System.out.println("🌐 Acesso ao URL: " + servletURL);
        
        try {
            // 1. Configurar e abrir a conexão
            URL url = new URL(servletURL);
            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("GET");
            connection.setConnectTimeout(5000); 
            
            // 2. Verificar o código de resposta
            int responseCode = connection.getResponseCode();
            
            if (responseCode == HttpURLConnection.HTTP_OK) { // 200 OK
                
                // 3. Ler o conteúdo da resposta
                StringBuilder response = new StringBuilder();
                try (BufferedReader in = new BufferedReader(
                     new InputStreamReader(connection.getInputStream()))) {
                    String inputLine;
                    while ((inputLine = in.readLine()) != null) {
                        response.append(inputLine);
                    }
                    return response.toString(); // Retorna o Context Path
                }
            } else {
                System.err.println("❌ Falha no acesso HTTP. Código de resposta: " + responseCode);
                System.out.println("🌐 + ❌ Verifique se o servidor web está a correr e se o URL está correto.");
                return null; 
            }
        } catch (Exception e) {
            System.err.println("\n❌ Erro de I/O ou URL malformado: " + e.getMessage());
            return null;
        }
    }
    
	/**
	 * Verifica se a conexão está ativa e é válida.
	 * @param con A conexão a verificar.
	 * @return true se a conexão é válida, false caso contrário.
	 */
	public static boolean isConnectionValid(Connection con) {
        final int TIMEOUT_SEGUNDOS=5;
	    if (con == null) 
	        return false;
	    try {
	        return con.isValid(TIMEOUT_SEGUNDOS); 
	    } catch (SQLException e) {
	        // e.printStackTrace(); 
	        return false;
	    }
	}
	
	/**
     * Fecha a conexão de forma segura (ignora se a conexão for null).
     * @param con A conexão a fechar.
     */
    public static void closeConnection(Connection con) {
        if (con != null) {
            try {
                con.close();
                // System.out.println("🔌 Conexão fechada.");
            } catch (SQLException e) {
                System.err.println("❌ Erro ao fechar a conexão.");
                e.printStackTrace();
            }
        }
    }

	// --- Getters (acesso às configurações) ---
	
    public SGBD getSGBD()  { return sgbd; }
	public String getDTB() { return database; }
	public String getDRV() { return drv; }
	public String getUSR() { return usr; }
	public String getURL() { return url; }
	
	public boolean isMySQL() { return sgbd==SGBD.MySQL; }
	public boolean isSQLServer() { return sgbd==SGBD.SQLServer; }
	
	// --- Setters (alteração dinâmica das configurações) ---

	/**
	 * Altera o nome da base de dados (o URL de conexão deve ser reconfigurado após esta chamada).
	 */
	public synchronized void setDTB(final String str) { 
		if (str != null) {
			database = str;
			build();
		}
		// Sugestão: Adicionar lógica para recalcular o URL aqui ou no getConnection.
	}
	
	/**
	 * Altera a palavra passe do utilizador da base de dados.
	 */
	public synchronized void setPWD(final String str) { 
		if (str != null) 
			pwd = str; 
	}
	
	/**
	 * Altera o nome do utilizador da base de dados.
	 */
	public synchronized void setUSR(final String str) { 
		if (str != null) 
			usr = str; 
	}
	/**
     * Devolve uma lista com todos os nomes de bases de dados (catalogs) existentes no servidor.
     * O método é sincronizado para garantir a segurança da thread, pois altera e restaura
     * temporariamente o campo de instância 'database'.
     *
     * @return Uma lista de Strings com os nomes das bases de dados, ou uma lista vazia em caso de erro.
     */
    public synchronized List<String> getBasesDeDados() {
        List<String> databases = new ArrayList<>();
        String dtb = database; // Guarda o valor original

        // A sincronização (na assinatura do método) protege esta secção:
        setDTB(""); // Altera o estado temporariamente para conexão ao servidor (sem DB específica)
        
        try (Connection con = getConnection()) {
            
            // Verifica se a conexão falhou
            if (con == null) {
                System.err.println("❌ Falha ao obter a conexão para listar bases de dados.");
                return databases;
            }
            
            // Obter os metadados da conexão
            DatabaseMetaData metaData = con.getMetaData();
            
            // Usar getCatalogs() para obter os nomes (Catálogos)
            try (ResultSet catalogs = metaData.getCatalogs()) {
            
                // Iterar sobre o ResultSet para extrair os nomes
                while (catalogs.next()) {
                    String dbName = catalogs.getString(1); // A coluna 1 é sempre o nome do Catalog/Database
                    databases.add(dbName);
                }
            }
            
        } catch (SQLException e) {
            System.err.println("🚨 Erro SQL ao obter a lista de bases de dados para " + sgbd + ".");
            System.err.println("Verifique as credenciais, o servidor e as permissões de acesso aos metadados.");
            e.printStackTrace();
        } finally {
        	// Restaura o valor original do campo 'database' antes de sair do bloco sincronizado.
            setDTB(dtb); 
        }
        return databases;
    }
    
    /**
     * Lista (imprime na consola) todos os nomes de bases de dados (catalogs) existentes no servidor.
     * Utiliza o método getBasesDeDados() para obter a lista.
     *
     * @return Uma lista de Strings com os nomes das bases de dados, ou uma lista vazia em caso de erro.
     */
    public List<String> listarBasesDeDados() {
        // Chama o método que contém a lógica sincronizada e de conexão
        List<String> databases = getBasesDeDados();

        System.out.println("⚙️ Bases de Dados encontradas no servidor '"+sgbd+"':");
        
        if (databases.isEmpty()) {
            System.out.println("⚠️ Nenhuma base de dados encontrada, ou houve um erro.");
            return databases;
        }

        // Iterar sobre a lista devolvida e imprimir
        for (String dbName : databases) {
            System.out.println("   -> " + dbName);
        }
        
        // Devolve a lista por conveniência, embora o principal seja a impressão.
        return databases;
    }
    
    /**
     * Obtém uma lista de todas as Tabelas e Vistas na base de dados (Catalog) atual 
     * e, opcionalmente, anexa o seu comentário de metadados.
     *
     * @param incluirComentarios Se true, o comentário é anexado ao nome do objeto (ex: "tabela [Comentário]").
     * @return Uma lista de Strings com os nomes dos objetos (com ou sem comentário).
     */
    public static List<String> getObjetos(boolean incluirComentarios) {
        Configura cfg=new Configura();
        List<String> listaObjetos = new ArrayList<>();
        
        // Obtém o nome da base de dados/Catalog a ser usado para filtragem
        String databaseName = cfg.getDTB(); 
        
        try (Connection con=cfg.getConnection()) {
            DatabaseMetaData metaData = con.getMetaData();
        
            // Filtros: Tipos de objetos a listar. Usamos "TABLE" e "VIEW".
            String[] tipos = {"TABLE", "VIEW"};

            // Obtém as informações sobre as tabelas e vistas
            // 💡 CORREÇÃO: Usamos 'databaseName' no primeiro argumento (Catalog Pattern)
            // e definimos o Schema Pattern como 'null' (ou '%' se necessário), 
            // para garantir que o filtro pelo nome da Base de Dados seja aplicado corretamente.
            try (ResultSet rs = metaData.getTables(databaseName, null, "%", tipos)) {
                
                while (rs.next()) {
                    String nomeObjeto = rs.getString("TABLE_NAME");
                    String objetoFormatado = nomeObjeto;
                    
                    if (incluirComentarios) {
                        try {
                            // Chama o método router para obter o comentário específico
                            String comentario = getObjectComment(con, cfg.getDTB(), cfg.getSGBD(), nomeObjeto);
                            
                            if (!comentario.isEmpty()) {
                                // Formata a string para incluir o comentário
                                objetoFormatado = nomeObjeto + " [" + comentario + "]";
                            }
                        } catch (IllegalArgumentException e) {
                            System.err.println("⚠️ Aviso: Não foi possível obter o comentário!");
                        }
                    }
                    
                    listaObjetos.add(objetoFormatado);
                }
            }
        } catch (SQLException ignore) {
            // Logica para ignorar a exceção.
        }
            
        return listaObjetos;
    }
    
    /**
     * 💡 Método Router: Obtém o comentário de uma Tabela ou Vista com base no SGBD.
     *
     * @param con A ligação ativa à base de dados.
     * @param dbType O tipo de SGBD (ex: "MySQL" ou "SQLServer").
     * @param objectName O nome da Tabela ou Vista.
     * @return O comentário do objeto.
     * @throws SQLException Se ocorrer um erro SQL.
     * @throws IllegalArgumentException Se o tipo de base de dados não for reconhecido.
     */
    public static String getObjectComment(Connection con, String database, Configura.SGBD dbType, String objectName) throws SQLException {
        if (dbType==SGBD.MySQL) {
            return getObjectCommentMySQL(con, database, objectName); 
            
        } else if (dbType==SGBD.SQLServer) {
            return getObjectCommentSQLServer(con, database, objectName);
        } else {
            throw new IllegalArgumentException(
                "Tipo de base de dados não suportado para obter comentários: " + dbType + ". Use 'MySQL' ou 'SQLServer'."
            );
        }
    }
    
    /**
     * 🔍 Obtém o comentário (MS_Description) de uma Tabela ou Vista no SQL Server, 
     * com filtro explícito pelo nome do esquema (schema).
     *
     * @param con A ligação ativa à base de dados SQL Server.
     * @param schemaName O nome do esquema onde a tabela/vista reside (ex: 'dbo').
     * @param objectName O nome da Tabela ou Vista.
     * @return O comentário do objeto, ou uma string vazia se não existir ou for nulo.
     * @throws SQLException Se ocorrer um erro SQL.
     */
    public static String getObjectCommentSQLServer(Connection con, String schemaName, String objectName) throws SQLException {
        String comment = "";
        
        // Concatena o schemaName e objectName para uso em OBJECT_ID
        // 💡 Alterado: OBJECT_ID agora recebe 'schema.object' como um parâmetro.
        String objectFullName = schemaName + "." + objectName;

        // T-SQL para procurar a propriedade estendida 'MS_Description'
        String tsql = "SELECT CAST(p.value AS NVARCHAR(MAX)) AS comment " +
                      "FROM sys.extended_properties AS p " +
                      "WHERE p.major_id = OBJECT_ID(?) " + // O parâmetro inclui agora o schema
                      "AND p.minor_id = 0 " +              
                      "AND p.name = N'MS_Description'";    

        try (PreparedStatement pstmt = con.prepareStatement(tsql)) {
            // Define o nome completo do objeto (schema.tabela)
            pstmt.setString(1, objectFullName); 

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    comment = rs.getString("comment");
                }
            }
        }
        return (comment != null) ? comment : "";
    }
    
	/**
    	 * 🔍 Obtém o comentário (texto) de uma Tabela ou Vista no MySQL, 
    	 * consultando a tabela de metadados information_schema.TABLES.
    	 *
    	 * @param con A ligação ativa à base de dados MySQL.
    	 * @param databaseName O nome da base de dados (schema) a consultar.
    	 * @param objectName O nome da Tabela ou Vista.
    	 * @return O comentário da tabela, ou uma string vazia se não existir ou for nulo.
    	 * @throws SQLException Se ocorrer um erro SQL.
    	 */
    	public static String getObjectCommentMySQL(Connection con, String databaseName, String objectName) throws SQLException {
    	    String comment = "";
    	    
    	    // SQL para extrair o COMMENT da tabela information_schema.TABLES
    	    String sql = "SELECT table_comment " +
    	                 "FROM information_schema.TABLES " +
    	                 "WHERE table_schema = ? " + 
    	                 "AND table_name = ?";
    	    try (PreparedStatement pstmt = con.prepareStatement(sql)) {
    	        
    	        // 1. O primeiro parâmetro '?' é definido como o nome da base de dados
    	        pstmt.setString(1, databaseName); 
    	        
    	        // 2. O segundo parâmetro '?' é definido como o nome da tabela/vista
    	        pstmt.setString(2, objectName); 

    	        try (ResultSet rs = pstmt.executeQuery()) {
    	            if (rs.next()) {
    	                comment = rs.getString("table_comment");
    	            }
    	        }
    	    }
    	    // Retorna a string vazia se o comentário for nulo ou não encontrado.
    	    return (comment != null) ? comment : "";
    	}
    
    public boolean criarBaseDeDados() {
    		return criarBaseDeDados(getDTB());
    }
    
    /**
     * Cria uma nova base de dados (Catálogo) no servidor SGBD.
     * O método é sincronizado para garantir a segurança da thread, pois manipula temporariamente 
     * o campo de instância 'database' para forçar a conexão ao servidor principal.
     *
     * @param nomeBD O nome que a nova base de dados deve ter.
     * @return true se a base de dados foi criada com sucesso, false caso contrário.
     */
    public synchronized boolean criarBaseDeDados(String nomeBD) {
        if (nomeBD == null || nomeBD.trim().isEmpty()) {
            System.err.println("❌ Erro: O nome da base de dados não pode ser vazio.");
            return false;
        }

        String dtb = getDTB(); // Guarda o valor original
        boolean sucesso = false;
        
        // 1. Altera o estado para forçar a conexão ao servidor principal (sem DB alvo)
        setDTB(""); 
        
        try (Connection con = getConnection()) {
            
            if (con == null) {
                System.err.println("❌ Falha ao obter a conexão para criar a base de dados.");
                return false;
            }

            // 2. Monta a instrução SQL
            String sql = "CREATE DATABASE " + nomeBD;

            // Nota: Para SQLServer, 'CREATE DATABASE' funciona.
            // Para MySQL, se a DB for criada sem 'IF NOT EXISTS', pode lançar exceção.
            // Poderia ser usada uma instrução mais robusta como: CREATE DATABASE IF NOT EXISTS " + nomeBD

            // 3. Executa a instrução DDL (Data Definition Language)
            try (Statement stmt = con.createStatement()) {
                
                System.out.println("\n⚙️ Executando DDL: " + sql + " (SGBD: " + this.sgbd + ")");
                
                // O executeUpdate() é usado para DDLs como CREATE, DROP, ALTER.
                stmt.executeUpdate(sql);
                sucesso = true;
                System.out.println("✅ Base de dados '" + nomeBD + "' criada com sucesso!");
            }

        } catch (SQLException e) {
            // Código de erro 1007 para MySQL e 1801 para SQLServer indicam DB já existente.
            // Para simplificar, tratamos a exceção como um erro geral na criação.
            System.err.println("🚨 Erro SQL ao criar a base de dados '" + nomeBD + "'.");
            System.err.println("Verifique se já existe ou se as permissões estão corretas.");
            e.printStackTrace();
        } finally {
        	// 4. Restaura o valor original do campo 'database'
            setDTB(dtb); 
        }
        
        return sucesso;
    }
    
    /**
     * Executa testes para uma dada instância de Configura:
     * 1. Listagem Inicial de Bases de Dados.
     * 2. Criação de uma DB de Teste.
     * 3. Listagem para confirmação.
     * 4. Eliminação da DB de Teste (Cleanup).
     * @param cfg A instância de Configura a ser testada (MySQL ou SQLServer).
     */
    private static void executarCompleto(Configura cfg) {
        
        String sgbdNome = cfg.getSGBD().name(); 
        
		System.out.println("A data de hoje no '"+sgbdNome+"' é: '"
		+DataFormatter.LocalDateToString(cfg.today())+"'");
		cfg.infoServer();
        // Cria um nome de DB
        String novaBDTeste = "A_TESTE_JDBC_" + sgbdNome.toUpperCase();

        // Abertura e validação de uma conexão inicial para status report
        try (Connection con = cfg.getConnection()) {
            if (con != null && isConnectionValid(con)) {
                System.out.println("✅ Conexão INICIAL ATIVA e VÁLIDA para " + sgbdNome + ".");
            } else {
                 System.err.println("❌ Não foi possível estabelecer conexão para o teste " + sgbdNome + ". Saltando o teste DDL.");
                 return;
            }
        } catch (SQLException e) {
             System.err.println("🚨 Erro na validação inicial da conexão para " + sgbdNome + ": " + e.getMessage());
             return;
        }
        
        // 1. LISTAGEM INICIAL DE BASE DE DADOS
        System.out.println("\n--- 2. Listagem Inicial de DBs ---");
        cfg.listarBasesDeDados(); 

        // 2. CRIAÇÃO DE BASE DE DADOS
        System.out.println("\n--- 3. CRIAÇÃO (DDL) de DB de Teste: " + novaBDTeste + " ---");
        cfg.criarBaseDeDados(novaBDTeste);

        // 3. CONFIRMAÇÃO E LISTAGEM INTERMÉDIA
        System.out.println("\n--- 3. Listagem Intermédia (Confirmação de Criação) ---");
        cfg.listarBasesDeDados();
        
        // 4. ELIMINAÇÃO (CLEANUP)
        System.out.println("\n--- 5. ELIMINAÇÃO (Cleanup) da DB de Teste: " + novaBDTeste + " ---");
        System.out.println("*** 🚧 Falta implementar ❓ ***");

        // 5. CONFIRMAÇÃO FINAL
        System.out.println("\n--- 6. Listagem Final (Confirmação de Eliminação) ---");
        cfg.listarBasesDeDados();
    }
    
	/**
	 * Devolve a data de hoje obtida a partir do SGBD configurado
	 */
	public LocalDate today() {
		String func = "CURDATE()";
		if(sgbd==SGBD.SQLServer)
			func = "GETDATE()";
		try (Connection con=getConnection(); 
			 Statement stm = con.createStatement();
			 ResultSet rs = stm.executeQuery("SELECT "+func+" AS Today")) {
			 if(rs.next())
				 return rs.getDate(1).toLocalDate();
		} catch (SQLException e) {
			System.err.println("\nOcorreu um erro na obtenção da data de hoje...");
			System.err.println("Ver detalhes abaixo:\n");
			System.err.println("-----SQLException-----");
			System.err.println("Message:  " + e.getMessage());
			System.err.println("SQLState:  " + e.getSQLState());
			System.err.println("Vendor:  " + e.getErrorCode());
		} 
		return null;
	}
	
	public LocalDate infoServer() {
		try (Connection con=getConnection()) { 
			DatabaseMetaData metaInformacaoBD = con.getMetaData();
			// Obter o nome do SGBD
			System.out.println("SGBD: "+metaInformacaoBD.getDatabaseProductName());
			// Obter o número máximo de conexões activas permitidas
			System.out.println("Nº Máximo de Ligações: "+metaInformacaoBD.getMaxConnections());
		} catch (SQLException e) {
			System.err.println("\nOcorreu um erro na obtenção de informações do servidor...");
			System.err.println("Ver detalhes abaixo:\n");
			System.err.println("-----SQLException-----");
			System.err.println("Message:  " + e.getMessage());
			System.err.println("SQLState:  " + e.getSQLState());
			System.err.println("Vendor:  " + e.getErrorCode());
		} 
		return null;
	}

    /* 💻 main
	* ===================================================================
	* 📢 TESTE COMPLETO: Conexão, Listagem, Criação e Eliminação de DBs.
	* ===================================================================
	*/
    
    public static void main(String[] args) {

		System.out.println("===================================================================");
		System.out.println("📢 TESTE: Conexão, Criação e Eliminação de DBs (DDL).");
		System.out.println("===================================================================");
		
		// --------------------------------------------------------------------------------
		// 🚀 TESTE 1: MYSQL
		// --------------------------------------------------------------------------------
		System.out.println("\n\n###################################################################");
		System.out.println("🧪 INÍCIO DO TESTE: MYSQL");
		System.out.println("###################################################################");
		
		
		// Instanciar a classe Configura para MySQL
		Configura cfgMySQL = new Configura(SGBD.MySQL);
		executarCompleto(cfgMySQL);

		System.out.println("\nParametros finais configurados para MySQL:");
		System.out.println("		Base de Dados: " + cfgMySQL.getDTB());
		System.out.println("		URL: " + cfgMySQL.getURL());

        System.out.println("\n\n===================================================================");
		System.out.println("🏁 FIM DO TESTE: MYSQL");
		System.out.println("===================================================================");
		// --------------------------------------------------------------------------------
		// 🚀 TESTE 2: SQLSERVER
		// --------------------------------------------------------------------------------
		System.out.println("\n\n###################################################################");
		System.out.println("🧪 INÍCIO DO TESTE: SQLSERVER");
		System.out.println("###################################################################");
		
		// Criar uma nova instância independente configurada para SQLServer
		Configura cfgSQLServer = new Configura(SGBD.SQLServer);
		executarCompleto(cfgSQLServer);

		System.out.println("\nParametros finais configurados para SQLServer:");
		System.out.println("		Base de Dados: " + cfgSQLServer.getDTB());
		System.out.println("		URL: " + cfgSQLServer.getURL());
        
        System.out.println("\n\n===================================================================");
		System.out.println("🏁 FIM DO TESTE: SQLSERVER");
		System.out.println("===================================================================");
	}	// --- 📢 Fim main (Exemplo de Uso) ---
}