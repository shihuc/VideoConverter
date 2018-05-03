package com.tk.video.web;

import javax.servlet.http.HttpServletRequest;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class UDPController {

	@RequestMapping(value = "/home")
	public String Home(HttpServletRequest req) {
		return "udp";
	}
	
	@RequestMapping(value = "/a")
	public String ssss(Object o) {
		System.out.println(o.toString());
		return "aaa";
	}

}
