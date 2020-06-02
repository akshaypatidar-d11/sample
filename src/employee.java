import java.sql.*;
import java.util.Scanner;

public class employee {
    public static void main(String[] args) {
        String url = "jdbc:mysql://localhost:3306/scratch";
        String user = "root";
        String pass = "root";
        System.out.println("Enter name, email, password");
        String name,email,password;
        Scanner sc = new Scanner(System.in);
        String temp = sc.nextLine();
        String[] argument =temp.split(" ");

        if(argument.length==3){
            name=argument[0];
            email=argument[1];
            password=argument[2];

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                java.sql.Connection conn = DriverManager.getConnection(url, user, pass);
                PreparedStatement stmt1 = conn.prepareStatement("INSERT INTO employees(name,email,password) VALUES(?,?,?);");
                stmt1.setString(1,name);
                stmt1.setString(2,email);
                stmt1.setString(3,password);
                stmt1.executeUpdate();
            }

            catch(Exception e)  {
                e.printStackTrace();
            }

        }
        else {
            System.out.println("Incorrect Number of Arguments");
        }


    }

}