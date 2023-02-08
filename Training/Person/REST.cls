Class Training.Person.REST Extends %CSP.REST
{

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
<!--
<Route Url="/class/:namespace/:classname" Method="GET" Call="GetClass" Cors="true"/>
<Map Prefix="/docserver" Forward="%Api.v1.DocServer"/>
-->
<Route Url="/test1" Method="GET" Call="test1" Cors="true"/>
<Route Url="/test2/:data1/:data2" Method="GET" Call="test2" Cors="true"/>
<Route Url="/test1" Method="POST" Call="test1POST" Cors="true"/>
<Route Url="/image" Method="POST" Call="SaveImage" Cors="true"/>

</Routes>
}

ClassMethod test2(data1 As %String, data2 As %String) As %Status
{
	set j={}
	set j.InputData1=data1
	set j.InputData2=data2
	do j.%ToJSON()
	return $$$OK
}

ClassMethod test1() As %Status [ Language = objectscript ]
{
	#dim ex As %Exception.AbstractException
	#dim %request As %CSP.Request
	set status=$$$OK
	try {
		set moji=%request.Get("q")
		
		//json
		set returnjson={}
		set returnjson.json={}
		set returnjson.json.Message="POST要求実行終了しました"
		set returnjson.json.Status="Good"
		set returnjson.json.Test=moji    //クエリパラメータからとった情報をセットしてます
		//JSONの出力
		do returnjson.%ToJSON()
	}
	catch ex {
		set status=ex.AsStatus()
	}
	quit status
}

ClassMethod test1POST() As %Status [ Language = objectscript ]
{
	#dim ex As %Exception.AbstractException
	#dim %request As %CSP.Request
	set status=$$$OK
	hang 20
	try {
		set moji=%request.Get("q")
		//Body
		set body=%request.Content.Read()
		
		/*
			IRIS内でJSONを操作する場合、JSONオブジェクト（ダイナミックオブジェクトとも呼びます）
			を利用する方法と、JSON文字列を作る方法の両方が利用できます。
			以下の例は、JSONオブジェクト（ダイナミックオブジェクト）を利用する例です。
	もしSET文でJSON文字列を作る場合は、以下の文法になります。
	set jsonmoji="{""Result"":{""Message"":""POST要求実行終了しました"",""Status"":""Good""},""QueryParameter"":""あいうえお"",""BodyText"":""今日は快晴です""}"
			JSON文字列を設定することもできますが、二重引用符の指定が多くなり書きにくさがあるので
			例では、JSONオブジェクトとして情報を設定しています。
			
			（ご参考）JSON文字列からJSONオブジェクトへの変換
				set jsonobj={}.%FromJSON(jsonmoji)
		*/
		set returnjson={}
		set returnjson.Result={}
		set returnjson.Result.Message="POST要求実行終了しました"
		set returnjson.Result.Status="Good"
		set returnjson.QueryParameter=moji   //クエリパラメータからとった情報をセットしてます
		set returnjson.BodyText=body  //Bodyの情報をセットしてます
		//JSONの出力
		do returnjson.%ToJSON()
	}
	catch ex {
		set status=ex.AsStatus()
	}
	quit status
}

/// Specifies the default character set for the page.  This can be overriden using the
/// &lt;CSP:CONTENT CHARSET=&gt; tag, or by setting the <b>%response</b>.CharSet property
/// in the <method>OnPreHTTP</method> method.  If this parameter is not specified, then
/// for the default charset is utf-8.
Parameter CHARSET = "utf-8";

/// Specifies the default content type for the page.  This can be overriden using the
/// &lt;CSP:CONTENT TYPE=&gt; tag, or by setting the <b>%response</b>.ContentType property
/// in the <method>OnPreHTTP</method> method.  The default value if this parameter is
/// not set is text/html.
Parameter CONTENTTYPE = "application/json";

/// Specifies if input %request.Content or %request.MimeData values are converted from their
/// original character set on input. By default (0) we do not modify these and receive them
/// as a binary stream which may need to be converted manually later. If 1 then if there
/// is a 'charset' value in the request Content-Type or mime section we will convert from this
/// charset when the input data is text based. For either json or xml data with no charset
/// this will convert from utf-8 or honor the BOM if one is present.
Parameter CONVERTINPUTSTREAM = 1;

ClassMethod SaveImage() As %Status [ Language = objectscript ]
{
	#dim ex As %Exception.AbstractException
	#dim %request As %CSP.Request
	set status=$$$OK
	try {
		set savename="c:\temp\post-imagetest1.png"
		set bin=##class(%Stream.FileBinary).%New()
		do bin.LinkToFile(savename) 
		
		//HTTP要求から添付されるファイルのストリームを取得
		set mimedata = %request.NextMimeData("")
 
 		if $get(mimedata)="" {
  			do bin.CopyFrom(%request.Content)
  			//debug　後で消すもの
  			//set ^iijima="body kita!"
  			// --debug
  		}
  		else {
	  		do bin.CopyFrom(%request.GetMimeData(mimedata))
  		}
  		set status=bin.%Save()
  		if $$$ISERR(status) {
  			return status
  		}
	}
	catch ex {
		set status=ex.AsStatus()
	}
	return status   //quit status
}

}
