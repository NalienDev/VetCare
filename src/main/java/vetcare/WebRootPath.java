package vetcare;

import java.io.IOException;
import java.io.PrintWriter;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet que retorna o caminho real do sistema de ficheiros da aplicação.
 * Necessário para a classe Configura localizar o ficheiro db_config.properties
 */
@WebServlet("/WebRootPath")
public class WebRootPath extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("text/plain");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();

        
        // Retorna o caminho real da aplicação no servidor
        String realPath = getServletContext().getRealPath("/");
        out.print(realPath);
        out.flush();
    }
}