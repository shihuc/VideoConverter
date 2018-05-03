package com.tk.video.web;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.util.UUID;

public class FileUtils {
	// 生成文件路径
	private static String path = "D:\\test\\";

	// 文件路径+名称
	private static String filenameTemp;

	/**
	 * 创建文件
	 * 
	 * @param fileName
	 *            文件名称
	 * @param filecontent
	 *            文件内容
	 * @return 是否创建成功，成功则返回true
	 */
	public static boolean createFile(String fileName, String filecontent) {
		Boolean bool = false;
		filenameTemp = path + fileName + ".txt";// 文件路径+名称+文件类型
		File file = new File(filenameTemp);
		try {
			// 如果文件不存在，则创建新的文件
			if (!file.exists()) {
				file.createNewFile();
				bool = true;
				System.out.println("success create file,the file is " + filenameTemp);
				// 创建文件成功后，写入内容到文件里
			}
			writeFileContent(filenameTemp, filecontent);
		} catch (Exception e) {
			e.printStackTrace();
		}

		return bool;
	}

	/**
	 * 向文件中写入内容
	 * 
	 * @param filepath
	 *            文件路径与名称
	 * @param newstr
	 *            写入的内容
	 * @return
	 * @throws IOException
	 */
	public static boolean writeFileContent(String filepath, String newstr) throws IOException {
		Boolean bool = false;
		String filein = newstr + "\r\n";// 新写入的行，换行
		String temp = "";

		FileInputStream fis = null;
		InputStreamReader isr = null;
		BufferedReader br = null;
		FileOutputStream fos = null;
		PrintWriter pw = null;
		try {
			File file = new File(filepath);// 文件路径(包括文件名称)
			// 将文件读入输入流
			fis = new FileInputStream(file);
			isr = new InputStreamReader(fis);
			br = new BufferedReader(isr);
			StringBuffer buffer = new StringBuffer();

			// 文件原有内容
			for (int i = 0; (temp = br.readLine()) != null; i++) {
				buffer.append(temp);
				// 行与行之间的分隔符 相当于“\n”
				buffer = buffer.append(System.getProperty("line.separator"));
			}
			buffer.append(filein.getBytes("utf-8"));

			fos = new FileOutputStream(file);
			pw = new PrintWriter(fos);
			pw.write(buffer.toString().toCharArray());
			pw.flush();
			bool = true;
		} catch (Exception e) {
			// TODO: handle exception
			e.printStackTrace();
		} finally {
			// 不要忘记关闭
			if (pw != null) {
				pw.close();
			}
			if (fos != null) {
				fos.close();
			}
			if (br != null) {
				br.close();
			}
			if (isr != null) {
				isr.close();
			}
			if (fis != null) {
				fis.close();
			}
		}
		return bool;
	}

	/**
	 * 删除文件
	 * 
	 * @param fileName
	 *            文件名称
	 * @return
	 */
	public static boolean delFile(String fileName) {
		Boolean bool = false;
		filenameTemp = path + fileName + ".txt";
		File file = new File(filenameTemp);
		try {
			if (file.exists()) {
				file.delete();
				bool = true;
			}
		} catch (Exception e) {
			// TODO: handle exception
		}
		return bool;
	}

	public static void main(String[] args) {
		UUID uuid = UUID.randomUUID();
		createFile(uuid + "myfile", "我的梦说别停留等待,就让光芒折射泪湿的瞳孔,映出心中最想拥有的彩虹,带我奔向那片有你的天空,因为你是我的梦 我的梦");
	}

}
