<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ include file="/WEB-INF/jsp/layout/top.jsp" %>
	<h2 class="font-weight-extra-bold">실시간 모니터링</h2>
	<div class="row">
		<div class="col-lg-9">
			<div id="map" style="width:100%;height:95%;"></div>
		</div>
		<div class="col-lg-3">
			<div class="tabs tabs-vertical tabs-right tabs-navigation tabs-navigation-simple">
				<aside class="sidebar mt-2">
					<div class="header"><h5 class="font-weight-bold" style="font-size:18px">근로자 목록</h5></div>
					<div class="content">
						<div  style="overflow-y:auto; overflow-x:hidden; width:100%; height:340px;">
							<ul class="nav nav-list flex-column">
								<p id="workerList"></p>
							</ul>
						</div>	
					</div>
					<div class="footer">
						<button type="button" class="btn btn-primary mb-2" onclick="changeMarker('all')">전체보기 </button>&nbsp;&nbsp;&nbsp;
						<button type="button" class="btn btn-secondary mb-2" onclick="changeMarker('red')">미착용 보기</button>
					</div>
					<style>
						.header{
						    height: 40px;
						}
						.content{
						    max-width: 500px; 
						    height: 380px;
						    margin: 0 auto; 
						}
						.footer{
						    height:40px;
						}
					</style>
				</aside>
			</div>
		</div>
	</div>
<script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=84df5ba3fe6d380ae81cc0059ae8ae59"></script> 
<script>
	var mapContainer = document.getElementById('map'), // 지도를 표시할 div 
	    mapOption = { 
	        center: new kakao.maps.LatLng(36.798795, 127.074911), // 지도의 중심좌표 선문대 중앙 잔디밭 위도 경도임
	        level: 5 // 지도의 확대 레벨
	    };
	var map = new kakao.maps.Map(mapContainer, mapOption); // 지도를 생성합니다
	/* 	
	if (navigator.geolocation) { //현재 접속한 위치로 화면을 이동 해주는 부분, 하지만 GeoLocationg함수 자체 불량으로 다른 위치를 찍는 경우가 잦음(작동은 됨)
	    navigator.geolocation.getCurrentPosition(function(position) { // GeoLocation을 이용해서 접속 위치를 얻어옵니다
	        var lat = position.coords.latitude, // 위도
	        	lon = position.coords.longitude; // 경도
	        	
	        var locPosition = new kakao.maps.LatLng(lat, lon) // 마커가 표시될 위치를 geolocation으로 얻어온 좌표로 생성합니다
	        map.setCenter(locPosition);
	    });
	} else { // HTML5의 GeoLocation을 사용할 수 없을때
	    alert("이 브라우저에서는 Geolocation이 지원되지 않습니다.")
	} 
	*/
	var greenImageSrc = 'https://ifh.cc/g/Hmeat5.png' // 초록색  지도마크 주소
	var redImageSrc = 'https://ifh.cc/g/r766V3.png' // 빨강색  지도마크 주소
	imageSize = new kakao.maps.Size(64, 69), // 마커이미지의 크기입니다
	imageOption = {offset: new kakao.maps.Point(27, 69)}; // 마커이미지의 옵션입니다. size 와 option중 하나만 변경 시 확대 및 축소시 마커좌표 어긋나게 됨

	var greenMarkerImage = new kakao.maps.MarkerImage(greenImageSrc, imageSize, imageOption) // 마커의 이미지정보를 가지고 있는 초록 지도마커 생성
	var redMarkerImage = new kakao.maps.MarkerImage(redImageSrc, imageSize, imageOption) // 마커의 이미지정보를 가지고 있는 빨강 지도마커 생성
	var markers = []; // 모든 마커를 가지고 있는 마커 배열
	var redMarkers = []; // 미착용 관련 마커를 가지고 있는 마커 배열
	
	function changeMarker(type){ // 착용 or 미착용 선택에 따라 마커들을 표시해주는 함수
	    var showAllMarkers = document.getElementById('all');
	    var redMarkers = document.getElementById('red');
	    if (type === 'all') { // 전체보기가 선택되었을 때
	        setMarkers(map);
	        setRedMarkers(map);
	    } else if (type === 'red') { // 미착용 보기가 선택되었을 때
	    	setMarkers(null);
	        setRedMarkers(map);
	    } 
	}
	
	function setMarkers(map) { // 모든 마커들의 지도 표시 여부를 설정하는 함수
		for (var i = 0; i < markers.length; i++) {
			markers[i].setMap(map);
		}
	}
	
	function setRedMarkers(map) { // 모든 미착용 마커들의 지도 표시 여부 설정하는 함수
		for (var i = 0; i < redMarkers.length; i++) {
			redMarkers[i].setMap(map);
		}
	}
	
	function panToMarker(code) { //해당 위치로 지도 부드럽게 이동시키기
		var latlng = markers[code].getPosition();
		map.panTo(latlng);
	}
	reCall(); // 초기 호출
	setInterval(reCall, 30000); // 반복하며 30초마다 지도를 호출
	
	function reCall() {
		var xhr = new XMLHttpRequest();
		xhr.onreadystatechange = function() {
			if (xhr.readyState === xhr.DONE) {
				if (xhr.status === 200 || xhr.status === 201) {
					var rows = JSON.parse(xhr.responseText);
					if (rows.length === 0) {
						//document.getElementById("workerList").innerHTML = "근무중인 근로자가 없습니다";
					} else {
						// 근로자 부분
						var html = "";
						for (var i = 0; i < rows.length; i++) {
							html += "	<li class=nav-item>";
							html += " 		<a class=nav-link onclick=panToMarker(" + i + ")>";
							html += "		" + rows[i].worker.name + " : ";
							if (rows[i].isWear == 'Y') {
								html += "착용";
							} else {
								html += "미착용";
							}
							html += "		</a>";
							html += "	</li>";
						}		
						document.getElementById("workerList").innerHTML = html;
						
						// 지도 부분
						setMarkers(null);
						setRedMarkers(null);
						markers = []; // 일정 시간마다 ajax를 통한 지도 마커 재배열 시 마커 배열들을 빈 배열로 만들기
						redMarkers = [];
						
						var iwContent = '<div style="padding:1px;text-align:center;width:150px;font-weight:bold">' // 인포윈도우 글씨체 설정
						var positions = []; // 마커를 여러개 표시할 위치
						for (var i = 0; i < rows.length; i++) {
							positions.push({
								content: iwContent + rows[i].worker.name + '</div>' 
								+ iwContent + rows[i].worker.phoneNumber.substring(0,3) + "-" 
								+ rows[i].worker.phoneNumber.substring(3,7) + "-" + rows[i].worker.phoneNumber.substring(7,11) + '</div>', 
							    latlng: new kakao.maps.LatLng(rows[i].latitude, rows[i].longitude)
							});
						}
						for (var i = 0; i < rows.length; i++) {
							if ('Y' == rows[i].isWear) {
								var marker = new kakao.maps.Marker({ // 마커를 생성합니다
									map: map, // 마커를 표시할 지도
									position: positions[i].latlng, // 마커의 위치
									image: greenMarkerImage // 마커이미지 설정 
								});
								
								markers.push(marker); // 초록 마커를 모든 마커 배열에 저장
							} else {
								var marker = new kakao.maps.Marker({ // 마커를 생성합니다
									map: map, // 마커를 표시할 지도
									position: positions[i].latlng, // 마커의 위치
									image: redMarkerImage // 마커이미지 설정 
								});
								
								markers.push(marker); // 빨강 마커를 모든 마커 배열에 저장
								redMarkers.push(marker); // 빨강 마커를 미착용 마커 배열에 저장
							}
							var infowindow = new kakao.maps.InfoWindow({ // 마커에 표시할 인포윈도우를 생성합니다 
								content: positions[i].content // 인포윈도우에 표시할 내용
							});
							
							(function(marker, infowindow) {
								// 마커에 mouseover 이벤트를 등록하고 마우스 오버 시 인포윈도우를 표시
								kakao.maps.event.addListener(marker, 'mouseover', function() {
									infowindow.open(map, marker);
								});
								
								// 마커에 mouseout 이벤트를 등록하고 마우스 아웃 시 인포윈도우를 닫음
								kakao.maps.event.addListener(marker, 'mouseout', function() {
									infowindow.close();
								});
							})(marker, infowindow);
						}					
					}
				} else {
					console.error(xhr.responseText);
				}
			}
		};
		xhr.open("GET", "${pageContext.request.contextPath}" + "/map/monitoring", true);
		xhr.send();
	};
</script>
<%@ include file="/WEB-INF/jsp/layout/bottom.jsp" %>