package reinforcement_learning.business;

import java.sql.*;
import java.util.*;
import java.util.Calendar;
import java.util.Date;
import java.math.BigDecimal;
import static reinforcement_learning.values.Constants.*;
import static reinforcement_learning.values.Variables.*;


public class DaoAbstruct{

	final private String driver;
	final private String server;
	final private String dbname;
	final private String url;
	final private String user;
	final private String password;

	protected Connection con;

	PropertiesReader propReader = new PropertiesReader();
	protected Statement stmt = null;

	Calendar calendar = Calendar.getInstance();
	private String getDriver(){
		return(this.driver);
	}

	private String getUrl(){
		return(this.url);
	}

	private String getUser(){
		return(this.user);
	}

	private String getPassword(){
		return(this.password);
	}

	public DaoAbstruct() {

		// JDBCドライバの指定
		this.driver = "com.mysql.jdbc.Driver";

		// データベースの指定
		this.server   = "localhost";      // MySQLサーバ ( IP または ホスト名 )
		this.dbname   = "FX";         // データベース名
		this.url = "jdbc:mysql://" + server + "/" + dbname + "?useUnicode=true&characterEncoding=UTF8";
		this.user     = "FX_USER";         // データベース作成ユーザ名
		this.password = "FX_USER";     // データベース作成ユーザパスワード

		DBcon();

		try{
			stmt = con.createStatement();
		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);

		}
	}

	private void DBcon(){
		
		try{
			// JDBCドライバの登録
			Class.forName(this.getDriver());

			// データベースとの接続
			con = DriverManager.getConnection(getUrl(), getUser(), getPassword());
			con.setAutoCommit(false);

		} catch(SQLException e){
			System.err.println("SQL failed.");
			e.printStackTrace();
			System.exit(2);

		} catch(ClassNotFoundException ex){
			ex.printStackTrace();
			System.exit(2);
		}
	}

	public void closeConnection(){

		// コネクション切断
		try{
			con.close();

		} catch(SQLException e) {
			System.out.println("MySQL Close error.");
		}
	}
}
