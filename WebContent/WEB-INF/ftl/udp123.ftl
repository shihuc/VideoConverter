<!DOCTYPE html>
<!--
 *  Copyright (c) 2015 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree.
-->
<html>
<head>
<meta charset="utf-8">
<meta name="description" content="WebRTC code samples">
<meta name="viewport" content="width=device-width, user-scalable=yes, initial-scale=1, maximum-scale=1">
<meta itemprop="description" content="Client-side WebRTC code samples">
<!--   <meta itemprop="image" content="../../../images/webrtc-icon-192x192.png"> -->
<meta itemprop="name" content="WebRTC code samples">
<meta name="mobile-web-app-capable" content="yes">
<meta id="theme-color" name="theme-color" content="#ffffff">
<script type="text/javascript" src="js/jquery-2.1.1.min.js"></script>
<base target="_blank">
<title>MediaStream Recording</title>
<!--   <link rel="icon" sizes="192x192" href="../../../images/webrtc-icon-192x192.png"> -->
<!--   <link href="//fonts.googleapis.com/css?family=Roboto:300,400,500,700" rel="stylesheet" type="text/css"> -->
<!--   <link rel="stylesheet" href="../../../css/main.css"> -->
<!--   <link rel="stylesheet" href="css/main.css"> -->
</head>
<body>
		<div id="container">
				<h1>
						<a href="//webrtc.github.io/samples/" title="WebRTC samples homepage">WebRTC samples</a> <span>MediaRecorder</span>
				</h1>
				<p>
						This demo requires Firefox 29 or later, or Chrome 47 or later with <strong>Enable experimental Web Platform features</strong> enabled from chrome://flags.
				</p>
				<!--     <p>For more information see the MediaStream Recording API <a href="http://w3c.github.io/mediacapture-record/MediaRecorder.html" title="W3C MediaStream Recording API Editor's Draft">Editor's&nbsp;Draft</a>.</p> -->
				<video id="gum" autoplay muted></video>
				<video id="recorded" autoplay loop></video>
				<div>
						<button id="record" disabled>Start Recording</button>
						<button id="play" disabled>Play</button>
						<button id="download" disabled>Download</button>
				</div>
				<!--     <a href="https://github.com/webrtc/samples/tree/gh-pages/src/content/getusermedia/record" title="View source for this page on GitHub" id="viewSource">View source on GitHub</a> -->
		</div>
		<!-- include adapter for srcObject shim -->
		<script type="text/javascript">
/*
*  Copyright (c) 2015 The WebRTC project authors. All Rights Reserved.
*
*  Use of this source code is governed by a BSD-style license
*  that can be found in the LICENSE file in the root of the source
*  tree.
*/

// This code is adapted from
// https://rawgit.com/Miguelao/demos/master/mediarecorder.html
$(function() {
	
	var url = "ws://10.90.13.61:8080/VideoConverter/websocket";

	var webSocket = null;
	if (webSocket == null) {
		webSocket = new WebSocket(url);
	}

	webSocket.onerror = function(event) {
		console.log(event.data);
	};

	webSocket.onopen = function(event) {
		webSocket.send("666666666666666666666");
	};

	//监听窗口关闭事件，当窗口关闭时，主动去关闭websocket连接，防止连接还没断开就关闭窗口，server端会抛异常。  
	window.onbeforeunload = function() {
		webSocket.onclose();
	};

	//连接发生错误的回调方法
	webSocket.onerror = function() {
		console.log("WebSocket连接发生错误");
		webSocket = new WebSocket(url);
	};

	//连接关闭的回调方法  
	webSocket.onclose = function() {
		console.log("WebSocket连接关闭");
		webSocket = new WebSocket(url);
	};
	//webSocket.binaryType = "arraybuffer" ;
	//接收到消息的回调方法
	webSocket.onmessage = function(event) {
		console.log("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
	};
	
'use strict';

/* globals MediaRecorder */

var mediaSource = new MediaSource();
mediaSource.addEventListener('sourceopen', handleSourceOpen, false);
var mediaRecorder;
var recordedBlobs;
var sourceBuffer;

var gumVideo = document.querySelector('video#gum');
var recordedVideo = document.querySelector('video#recorded');

var recordButton = document.querySelector('button#record');
var playButton = document.querySelector('button#play');
var downloadButton = document.querySelector('button#download');
recordButton.onclick = toggleRecording;
playButton.onclick = play;
downloadButton.onclick = download;

// window.isSecureContext could be used for Chrome
var isSecureOrigin = location.protocol === 'https:' ||
location.hostname === 'localhost';
if (!isSecureOrigin) {
  alert('getUserMedia() must be run from a secure origin: HTTPS or localhost.' +
    '\n\nChanging protocol to HTTPS');
  location.protocol = 'HTTPS';
}

var constraints = {
  audio: true,
  video: true
};

function handleSuccess(stream) {
  recordButton.disabled = false;
  console.log('getUserMedia() got stream: ', stream);
  window.stream = stream;
  if (window.URL) {
    gumVideo.src = window.URL.createObjectURL(stream);
  } else {
    gumVideo.src = stream;
  }
}

function handleError(error) {
  console.log('navigator.getUserMedia error: ', error);
}

navigator.mediaDevices.getUserMedia(constraints).
    then(handleSuccess).catch(handleError);

function handleSourceOpen(event) {
  console.log('MediaSource opened');
  sourceBuffer = mediaSource.addSourceBuffer('video/webm; codecs="vp8"');
  console.log('Source buffer: ', sourceBuffer);
}

recordedVideo.addEventListener('error', function(ev) {
  console.error('MediaRecording.recordedMedia.error()');
  alert('Your browser can not play\n\n' + recordedVideo.src
    + '\n\n media clip. event: ' + JSON.stringify(ev));
}, true);

function handleDataAvailable(event) {
  if (event.data && event.data.size > 0) {
    recordedBlobs.push(event.data);
    var reader = new FileReader();
	reader.addEventListener("loadend", function() {
	   // reader.result 包含转化为类型数组的blob
	   //console.log(reader.result);
	   var reader = new FileReader();
		reader.addEventListener("loadend", function() {
			// reader.result 包含转化为类型数组的blob
			// console.log(reader.result);
			var buf = new Uint8Array(reader.result);
			
			var dataString = Utf8ArrayToStr(buf);
			console.log(dataString);
			webSocket.send(dataString);
		});
		reader.readAsArrayBuffer(event.data);
   		
   		
	});
	reader.readAsArrayBuffer(event.data);
    

    
    
  }
}

function handleStop(event) {
  console.log('Recorder stopped: ', event);
}

function toggleRecording() {
  if (recordButton.textContent === 'Start Recording') {
    startRecording();
  } else {
    stopRecording();
    recordButton.textContent = 'Start Recording';
    playButton.disabled = false;
    downloadButton.disabled = false;
  }
}

function startRecording() {
  recordedBlobs = [];
  var options = {mimeType: 'video/webm;codecs=vp9'};
  if (!MediaRecorder.isTypeSupported(options.mimeType)) {
    console.log(options.mimeType + ' is not Supported');
    options = {mimeType: 'video/webm;codecs=vp8'};
    if (!MediaRecorder.isTypeSupported(options.mimeType)) {
      console.log(options.mimeType + ' is not Supported');
      options = {mimeType: 'video/webm'};
      if (!MediaRecorder.isTypeSupported(options.mimeType)) {
        console.log(options.mimeType + ' is not Supported');
        options = {mimeType: ''};
      }
    }
  }
  try {
    mediaRecorder = new MediaRecorder(window.stream, options);
  } catch (e) {
    console.error('Exception while creating MediaRecorder: ' + e);
    alert('Exception while creating MediaRecorder: '
      + e + '. mimeType: ' + options.mimeType);
    return;
  }
  console.log('Created MediaRecorder', mediaRecorder, 'with options', options);
  recordButton.textContent = 'Stop Recording';
  playButton.disabled = true;
  downloadButton.disabled = true;
  mediaRecorder.onstop = handleStop;
  mediaRecorder.ondataavailable = handleDataAvailable;
  mediaRecorder.start(10); // collect 10ms of data
  console.log('MediaRecorder started', mediaRecorder);
}

function stopRecording() {
  mediaRecorder.stop();
  console.log('Recorded Blobs: ', recordedBlobs);
  recordedVideo.controls = true;
}

function play() {
  var superBuffer = new Blob(recordedBlobs, {type: 'video/webm'});
  recordedVideo.src = window.URL.createObjectURL(superBuffer);
}

function download() {
  var blob = new Blob(recordedBlobs, {type: 'video/webm'});
  var url = window.URL.createObjectURL(blob);
  var a = document.createElement('a');
  a.style.display = 'none';
  a.href = url;
  a.download = 'test.webm';
  document.body.appendChild(a);
  a.click();
  setTimeout(function() {
    document.body.removeChild(a);
    window.URL.revokeObjectURL(url);
  }, 100);
}



function Utf8ArrayToStr(array) {
    var out, i, len, c;
    var char2, char3;

    out = "";
    len = array.length;
    i = 0;
    while(i < len) {
    c = array[i++];
    switch(c >> 4)
    { 
      case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7:
        // 0xxxxxxx
        out += String.fromCharCode(c);
        break;
      case 12: case 13:
        // 110x xxxx   10xx xxxx
        char2 = array[i++];
        out += String.fromCharCode(((c & 0x1F) << 6) | (char2 & 0x3F));
        break;
      case 14:
        // 1110 xxxx  10xx xxxx  10xx xxxx
        char2 = array[i++];
        char3 = array[i++];
        out += String.fromCharCode(((c & 0x0F) << 12) |
                       ((char2 & 0x3F) << 6) |
                       ((char3 & 0x3F) << 0));
        break;
    }
    }

    return out;
}


});







</script>
</body>
</html>