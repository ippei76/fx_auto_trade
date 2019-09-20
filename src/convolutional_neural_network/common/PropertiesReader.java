package convolutional_neural_network.common;

import java.io.*;
import java.util.Properties;
import java.io.FileInputStream;
import java.io.FileInputStream;

public class PropertiesReader{

	final public static String propertyFile = "/root/projects/fx/src/convolutional_neural_network/values/PropertyValues.properties";

	public static Properties properties = new Properties();
	
	// privateコンストラクタでインスタンス生成を抑止
	private PropertiesReader(){}

	public static int PropertiesOpen(){

		try {
			System.err.println("Property Open Success.");
			InputStream inputStream = new FileInputStream(propertyFile);
			properties.load(inputStream);
			inputStream.close();

		} catch (IOException e) {
			System.err.println("Cannot open " + propertyFile + ".");
			e.printStackTrace();
			System.exit(2);

		}
		return(0);
	}
}
