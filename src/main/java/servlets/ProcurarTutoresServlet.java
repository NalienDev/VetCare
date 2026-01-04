package servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import org.json.JSONArray;
import org.json.JSONObject;

import vetcare.Configura;
import vetcare.Manipula;

@WebServlet("/procurarTutores")
public class ProcurarTutoresServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

	@Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException{
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		
		String query = request.getParameter("query");
		JSONArray result = new JSONArray();

		if (query != null && query.length() >= 2) {
		    Configura cfg = new Configura();
		    Manipula manipula = new Manipula(cfg);
		    
		    try {
		        String sql = "SELECT NIF, nomeCompleto FROM cliente WHERE nomeCompleto LIKE ? ORDER BY nomeCompleto LIMIT 10";
		        
		        Connection con = manipula.getLigacao();
		        PreparedStatement ps = con.prepareStatement(sql);
		        ps.setString(1, "%" + query + "%");
		        ResultSet rs = ps.executeQuery();
		        
		        while (rs.next()) {
		            JSONObject tutor = new JSONObject();
		            tutor.put("nif", rs.getString("NIF"));
		            tutor.put("nome", rs.getString("nomeCompleto"));
		            result.put(tutor);
		        }
		        
		        rs.close();
		        ps.close();
		        
		    } catch (Exception e) {
		        e.printStackTrace();
		    } finally {
		        manipula.desligar();
		    }
		}

		// Send JSON response
		PrintWriter out = response.getWriter();
		out.print(result.toString());
		out.flush();
	}
}