package vetcare;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class VetCare {

	// Por agora valores de config hardcoded, serão carregados de um ficheiro properties, através da classe, configura
	private static final String DATABASE = "vetcare";
	private static final String SERVER = "localhost";
	private static final String URL = "jdbc:mysql://" + SERVER +":3306/" + DATABASE;
	private static final String USER = "root";
	private static final String PASSWORD = "root";
	
	public static void main(String[] args) {
		VetCare vetCare = new VetCare();
		vetCare.criarConexao();
	}
	
	
	public void criarConexao() {
		try (Connection conn = DriverManager.getConnection(URL, USER, PASSWORD)) {
			System.out.println("Conexão ao MySQL estabelecida!");
			
			// ... Lógica de execução de instruções SQL (Statement, PreparedStatement)
			
			System.out.println("Vai fechar a conexão à base de dados... ");
		} catch (SQLException e) {
			// O ClassNotFoundException já não é necessário capturar aqui
			System.err.println("Erro de conexão à BD: " + e.getMessage());
		}
		
		// O conn.close() é invocado automaticamente ao sair do bloco try-with-resources
		
		System.out.println("Finalizou a execução. ");
	}

}
