package servlets;

import java.io.*;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;


import vetcare.Configura;
import vetcare.Manipula;

@WebServlet("/fotoAnimal")

public class FotoAnimalServlet extends HttpServlet {

	private static final long serialVersionUID = 1L;

	@Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID obrigatório");
            return;
        }

        int idFicha;
        try {
            idFicha = Integer.parseInt(idParam);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "ID inválido");
            return;
        }

        Configura cfg = new Configura();
        Manipula manipula = new Manipula(cfg);

        try {
            Connection con = manipula.getLigacao();

            String sql = "SELECT fotografia FROM caracteristicasFic WHERE idFicha = ?";
            PreparedStatement ps = con.prepareStatement(sql);
            ps.setInt(1, idFicha);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                Blob blob = rs.getBlob("fotografia");
                if (blob != null && blob.length() > 0) {
                    response.setContentType("image/jpeg");
                    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");

                    InputStream in = blob.getBinaryStream();
                    OutputStream out = response.getOutputStream();

                    byte[] buffer = new byte[4096];
                    int bytesRead;
                    while ((bytesRead = in.read(buffer)) != -1) {
                        out.write(buffer, 0, bytesRead);
                    }

                    out.flush();
                    in.close();
                    out.close();

                    rs.close();
                    ps.close();
                    return;
                }
            }

            rs.close();
            ps.close();

            // fallback imagem default
            response.sendRedirect(request.getContextPath() + "/images/default-animal.png");

        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/images/default-animal.png");
        } finally {
            manipula.desligar();
        }
    }
}
