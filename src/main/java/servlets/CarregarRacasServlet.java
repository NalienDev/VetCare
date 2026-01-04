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

@WebServlet("/carregarRacas")
public class CarregarRacasServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	@Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	
		response.setContentType("application/json");
		response.setCharacterEncoding("UTF-8");
		
		String especie = request.getParameter("especie");
		JSONArray result = new JSONArray();

		if (especie != null && !especie.isEmpty()) {
		    Configura cfg = new Configura();
		    Manipula manipula = new Manipula(cfg);
		    
		    try {
		        String sql = "SELECT nomeRaca FROM raca WHERE nomeComum = ? ORDER BY nomeRaca";
		        
		        Connection con = manipula.getLigacao();
		        PreparedStatement ps = con.prepareStatement(sql);
		        ps.setString(1, especie);
		        ResultSet rs = ps.executeQuery();
		        
		        while (rs.next()) {
		            JSONObject raca = new JSONObject();
		            raca.put("nomeRaca", rs.getString("nomeRaca"));
		            result.put(raca);
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