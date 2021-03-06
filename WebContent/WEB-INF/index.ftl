<#assign baseUrl=request.getContextPath()>
<!DOCTYPE html>
<html lang="UTF-8">
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
	<meta name="viewport" content="initial-scale=1.0, user-scalable=no" />
	<style type="text/css">
	body, html,#allmap {width: 100%;height: 100%;overflow: hidden;margin:0;font-family:"微软雅黑";}
	</style>
	<script type="text/javascript" src="http://api.map.baidu.com/api?v=2.0&ak=EuQZy4q2kFskzCIImsMvnvwtHkkyEzAd"></script>
	<title>地图展示</title>
</head>
<body style="height:100%;width: 100%;font-size:0px">
	<input id="hiddenBaseUrl" type="hidden" value="${baseUrl}"/>
	<div style="width:70%;display: inline-block;" id="allmap"></div>
	<div style="width:30%; height:100%;display:inline-block; ">
		<form style="position:absolute;font-size:16px;top:5%;" id="submitForm">
			&nbsp;&nbsp;&nbsp;起点: <input type="text" name="startAddress" id="startAddress" value="复旦大学张江校区"/>
            <input type="hidden" id="hiddenStartLongitude" value="121.604569"/>
            <input type="hidden" id="hiddenStartLatitude" value="31.196348"/>
            <br/><br/>
			&nbsp;&nbsp;&nbsp;终点: <input type="text" name="endAddress" id="endAddress" value="人民广场"/>
			<input type="hidden" id="hiddenEndLongitude" value="121.478941"/>
            <input type="hidden" id="hiddenEndLatitude" value="31.236009"/>
            <br/><br/>
             &nbsp;&nbsp;&nbsp;<input type="radio" name="items" value="1" checked/>步行最少<br/>
             &nbsp;&nbsp;&nbsp;<input type="radio" name="items" value="2" />换乘最少<br/>
             &nbsp;&nbsp;&nbsp;<input type="radio" name="items" value="3" />时间最短<br/><br/>
			<input style="position:relative;left:40%;width:80px;height:30px;" type="button" value="查询" onclick="clickButton()">
		</form><br/>
        <div style="position:absolute;top:40%;width: 20%;height: 60%">
	        <label for="resultDiv" style="font-size:18px;position:relative;">display the result:</label><br/>
			<textarea id="resultDiv" style="background-color:#F5F5F5;width: 120%;height:90%;font-size:18px;word-wrap: break-word; " contenteditable="false">
	       
	        </textarea>
        </div>
	</div>
</body>
</html>
	
<script src="https://code.jquery.com/jquery-3.2.1.min.js"></script>
<script type="text/javascript">
	// 百度地图API功能
	var map = new BMap.Map("allmap");    // 创建Map实例
	map.centerAndZoom("上海", 16);  // 初始化地图,设置中心点坐标和地图级别  
	map.enableScrollWheelZoom(true);     //开启鼠标滚轮缩放
	var geocoder= new BMap.Geocoder(); 
	map.addEventListener("rightclick",function(e)
	{
	    RightClickMap(e.point);
	});

	function RightClickMap(point)
	{
        var EventStartMarker =function(map)
		{
            //addEventF是具体的菜单方法，要实现什么功能取决自身需求
            geocoder.getLocation(point, function(rs)
			{
                //addressComponents对象可以获取到详细的地址信息
                var addComp = rs.addressComponents;
                var site = addComp.district + ", " + addComp.street + ", " + addComp.streetNumber;
                //将对应的HTML元素设置值
                $("#startAddress").val(site);
                $("#hiddenStartLongitude").val(point.lng);
                $("#hiddenStartLatitude").val(point.lat);
            });
        };
        var EventEndMarker =function(map)
        {
            //addEventF是具体的菜单方法，要实现什么功能取决自身需求
            geocoder.getLocation(point, function(rs)
            {
                //addressComponents对象可以获取到详细的地址信息
                var addComp = rs.addressComponents;
                var site = addComp.district + ", " + addComp.street + ", " + addComp.streetNumber;
                //将对应的HTML元素设置值
                $("#endAddress").val(site);
                $("#hiddenEndLongitude").val(point.lng);
                $("#hiddenEndLatitude").val(point.lat);
            });
        };
	    var markerMenu = new BMap.ContextMenu();
        markerMenu.addItem(new BMap.MenuItem('设为起点',EventStartMarker.bind(map)));
        map.addContextMenu(markerMenu);

        var markerMenuEnd = new BMap.ContextMenu();
        markerMenu.addItem(new BMap.MenuItem('设为终点',EventEndMarker.bind(map)));
        map.addContextMenu(markerMenuEnd);
	}

	//提交按钮的点击事件
    function clickButton()
    {
    	//请在这里检查数据

    	
    	var baseUrl = $("#hiddenBaseUrl").val();
		$.ajax({
			url: baseUrl+"/submitsearch",
			type: 'POST',
			data: 
			JSON.stringify({
				"startAddress":$("#startAddress").val(),
				"startLongitude":$("#hiddenStartLongitude").val(),
				"startLatitude":$("#hiddenStartLatitude").val(),
				"endAddress":$("#endAddress").val(),
				"endLongitude":$("#hiddenEndLongitude").val(),
				"endLatitude":$("#hiddenEndLatitude").val(),
				"choose":$('input[name=items]:checked', '#submitForm').val()
			}),
			dataType: 'JSON',
			contentType: "application/json; charset=utf-8",
			success:function(data)
			{
				map.clearOverlays();
				var len = data.subwayList.length;
				var stationStart = new BMap.Point(data.subwayList[0].longitude,data.subwayList[0].latitude);
				// drawPoint(stationStart,data.subwayList[0].vertex);
				var stationEnd = new BMap.Point(data.subwayList[len-1].longitude,data.subwayList[len-1].latitude);
				// drawPoint(stationEnd,data.subwayList[len-1].vertex);
				var arrayList = [];
				for(var i=0;i<len;++i)
				{
					p = new BMap.Point(data.subwayList[i].longitude,data.subwayList[i].latitude);
					arrayList.push(p);
					drawPoint(p,data.subwayList[i].address);
				}
				showPoly(stationStart,stationEnd,arrayList);
				
				var placeStart = new BMap.Point(data.startPoint.longitude,data.startPoint.latitude);
				var placeEnd = new BMap.Point(data.endPoint.longitude,data.endPoint.latitude);
				var polyline = new BMap.Polyline([placeStart,stationStart]);
				map.addOverlay(polyline);
				var polylineEnd = new BMap.Polyline([stationEnd,placeEnd]);
				map.addOverlay(polylineEnd);
				
				drawPoint(placeStart,data.startPoint.address);
				drawPoint(placeEnd,data.endPoint.address);
				
				var str = data.startPoint.address;
				for (var i=0;i<len;++i)
				{
				    if (i == 0){
                        str+="&nbsp;&nbsp;-->&nbsp;&nbsp;" + data.subwayList[i].address;
					}
				    else {
                        str+="&nbsp;&nbsp;==&nbsp;&nbsp;"  + data.lineList[i - 1] + "&nbsp;&nbsp;=>&nbsp;&nbsp;" + data.subwayList[i].address;
					}
				}
				str += "&nbsp;&nbsp;-->&nbsp;&nbsp;" + data.endPoint.address + "\n";
				str+="步行距离为:&nbsp;&nbsp; "+ (data.startWalk + data.endWalk) + "&nbsp;米\n";
				str+="花费时间为:&nbsp;&nbsp; "+ data.minutes + "&nbsp;分钟";
				$("#resultDiv").html(str);
			},
			error:function(data)
			{
				alert("很抱歉,服务器出错!");
			}
		});
    }
    
    // 绘制marker（起点、经点、终点），添加文本标注
    function drawPoint(point,content)
    {
        let marker = new BMap.Marker(point);
        this.map.addOverlay(marker);
        var label = new BMap.Label(content,{
            offset:new BMap.Size(20,-10)
        });
        marker.setLabel(label);
    } 

    //绘制公交路线
    function showPoly(start,end,pointList)
    {
    	var line = new BMap.Polyline(pointList,{strokeColor:"blue", strokeWeight:3, strokeOpacity:0.7});
    	map.addOverlay(line);
    }
</script>
