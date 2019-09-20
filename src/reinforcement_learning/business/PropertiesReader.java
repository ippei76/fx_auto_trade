package reinforcement_learning.business;

import java.io.*;
import java.util.Properties;

class PropertiesReader{

	final String propertyFile = "properties/RL.properties";

	Properties properties = new Properties();

	public PropertiesReader(){

		try {
			properties.load(new FileInputStream(propertyFile));

		} catch (IOException e) {
			System.err.println("Cannot open " + propertyFile + ".");
		//	e.printStackTrace();
		//	System.exit(2);

		}
	}
}
