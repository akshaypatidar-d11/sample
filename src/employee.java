import java.sql.*;
import java.util.Scanner;

public class employee {


    public static Connection connect(){
        String url = "jdbc:mysql://localhost:3306/scratch";
        String user = "root";
        String pass = "root";
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            return DriverManager.getConnection(url, user, pass);
        }
        catch(Exception e)  {
            System.out.println(e);
        }
        return null;
    }

    public static int insert(String name, String email, String password){
        try {
            Connection conn = connect();
            PreparedStatement stmt1 = conn.prepareStatement("INSERT INTO employees(name,email,password) VALUES(?,?,?);");
            stmt1.setString(1,name);
            stmt1.setString(2,email);
            stmt1.setString(3,password);
            return stmt1.executeUpdate();
        }
        catch(Exception e)  {
            System.out.println(e);
        }
        return 0;
    }

    public static int update(String name, String email, String password){
        try {
            Connection conn = connect();
            PreparedStatement stmt1 = conn.prepareStatement("UPDATE employees SET name = ?, password = ? WHERE email = ?;");
            stmt1.setString(1,name);
            stmt1.setString(2,password);
            stmt1.setString(3,email);
            return stmt1.executeUpdate();
        }
        catch(Exception e)  {
            System.out.println(e);
        }
        return 0;
    }


    public static String read(String email){
        try {
            Connection conn = connect();
            PreparedStatement stmt1 = conn.prepareStatement("SELECT name,email FROM employees WHERE email = ?;");
            stmt1.setString(1,email);
            ResultSet rs = stmt1.executeQuery();

            if(rs.next()){
                return rs.getString("name");
            }
            else{
                return "The email is not registered";
            }
        }
        catch(Exception e)  {
            System.out.println(e);
        }
        return "";
    }

    public static int delete(String email){
        try {
            Connection conn = connect();
            PreparedStatement stmt1 = conn.prepareStatement("DELETE FROM employees WHERE email = ?;");
            stmt1.setString(1,email);
            return stmt1.executeUpdate();
        }
        catch(Exception e)  {
            System.out.println(e);
        }
        return 0;
    }


    public static void main(String[] args) {
        System.out.println("Select your operation.\n Press 1 for CREATE\n Press 2 for READ\n Press 3 for UPDATE\n Press 4 for DELETE ");
        Scanner sc = new Scanner(System.in);
        String temp = sc.nextLine();

        if( temp.equals("1")){
            System.out.println("Enter name, email, password");
            String name,email,password;
            temp = sc.nextLine();
            String[] argument =temp.split(" ");

            if(argument.length==3){
                name=argument[0];
                email=argument[1];
                password=argument[2];
                int status = insert(name,email,password);
                if(status > 0){
                    System.out.println("User Saved Successfully");
                }
                else{
                    System.out.println("Unable to save user");
                }
            }
            else {
                System.out.println("Incorrect Number of Arguments");
            }
        }
        else if(temp.equals("2")){
            // READ
            System.out.println("Enter email");
            System.out.println(read(sc.nextLine()));
        }
        else if(temp.equals("3")){
            //UPDATE
            System.out.println("Enter email");
            String email = sc.nextLine();
            System.out.println("Enter new name");
            String name = sc.nextLine();
            System.out.println("Enter new password");
            String password = sc.nextLine();
            int status = update(name,email,password);
            if(status > 0){
                System.out.println("User Updated Successfully");
            }
            else{
                System.out.println("Unable to update user");
            }

        }
        else if(temp.equals("4")){
            // DELETE
            System.out.println("Enter email");
            String email;
            int status = delete(sc.nextLine());
            if(status > 0){
                System.out.println("User Deleted Successfully");
            }

        }
        else{
            System.out.println("Invalid Operation\n");
        }
    }

}