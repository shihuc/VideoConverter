package com.tk.video.web;

import java.io.IOException;
import java.net.DatagramPacket;
import java.net.DatagramSocket;
import java.net.InetAddress;
import java.nio.ByteBuffer;
import java.util.HashMap;
import java.util.Map;

import javax.websocket.OnClose;
import javax.websocket.OnError;
import javax.websocket.OnMessage;
import javax.websocket.OnOpen;
import javax.websocket.Session;
import javax.websocket.server.ServerEndpoint;

import org.apache.log4j.Logger;
import org.springframework.stereotype.Component;

@Component
@ServerEndpoint(value = "/websocket")
public class UDPWebsocket {

	private Logger logger = Logger.getLogger(UDPWebsocket.class);

	private static final Map<String, UDPWebsocket> map = new HashMap<String, UDPWebsocket>();

	private Session session;

	public static final Map<String, UDPWebsocket> getSocketMap() {
		return map;
	}

	@OnMessage
	public void onMessage(Session session, ByteBuffer bb, boolean last) {
		try {
			if (session.isOpen()) {

				byte[] sentBuf = bb.array();

				DatagramSocket client = new DatagramSocket();
				InetAddress addr = InetAddress.getByName("10.90.7.10");
				int port = 7667;
				DatagramPacket sendPacket = new DatagramPacket(sentBuf, sentBuf.length, addr, port);
				client.send(sendPacket);
				client.close();

			}
		} catch (IOException e) {
			try {
				session.close();
			} catch (IOException e1) {
				// Ignore
			}
		}
	}

	/**
	 * 打开链接，并初始化session
	 * 
	 * @param session
	 */
	@OnOpen
	public void onOpen(Session session) {
		map.put("udpSocket", this);
		this.session = session;
		System.out.println("**********************************open**********************************");
	}

	/**
	 * 关闭通讯
	 */
	@OnClose
	public void onClose(Session session) {
		map.remove("udpSocket");
		System.out.println("***********************************close*********************************");
	}

	@OnError
	public void onError(Session session, Throwable error) {
		System.out.println("发生错误");
		// error.printStackTrace();
	}

	/**
	 * 自定义发送消息方法
	 * 
	 * @param message
	 * @throws IOException
	 */
	public void sendMessage(String message, String openId) {

		logger.info("即时通讯，发送到客户端的消息为 : " + message);

		UDPWebsocket client = map.get("udpSocket");
		try {
			if (client == null) {
				logger.info("会话连接断开...");
				return;
			}
			client.session.getBasicRemote().sendText(message);
			logger.info("消息发送成功");
		} catch (IOException e) {
			logger.info("发送消息到客户端失败 ：" + e.getMessage());
			try {
				client.session.close();
			} catch (IOException e1) {
				logger.info("发送消息到客户端失败 ：" + e1.getMessage());
			}
		}
	}

}
