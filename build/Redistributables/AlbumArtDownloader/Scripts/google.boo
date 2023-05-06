import System.IO
import System.Net
import AlbumArtDownloader.Scripts
import util

class GoogleImage(AlbumArtDownloader.Scripts.IScript):
	Name as string:
		get: return "GoogleImage"
	Version as string:
		get: return "0.21"
	Author as string:
		get: return "Alex Vallat"
	def Search(artist as string, album as string, results as IScriptResults):
		artist = StripCharacters("&.'\";:?!", artist)
		album = StripCharacters("&.'\";:?!", album)

		url = "https://www.google.com/search?q=" + EncodeUrl(artist + " " + album) + "&gbv=2&tbm=isch"

		request = System.Net.HttpWebRequest.Create(url) as System.Net.HttpWebRequest
		request.Accept = "text/html, application/xhtml+xml, */*"
		request.AutomaticDecompression = DecompressionMethods.GZip
		request.Headers.Add("Accept-Language","en-GB")
		request.UserAgent = "Mozilla/5.0 Firefox/25.0"

		imagesHtml = StreamReader(request.GetResponse().GetResponseStream()).ReadToEnd()

		imageMatches = Regex("<div[^>]+?class=\"rg_meta[^>]+>(?<json>[^<]+)<", RegexOptions.Singleline | RegexOptions.IgnoreCase).Matches(imagesHtml)
		
		results.EstimatedCount = imageMatches.Count
		
		json = JavaScriptSerializer()

		for imageMatch as Match in imageMatches:
			imageData = json.Deserialize[of ImageData](imageMatch.Groups["json"].Value);
			
			//title = System.Web.HttpUtility.HtmlDecode(imageMatch.Groups["title"].Value.Replace("\\u0026","&"))
			title = imageData.pt
			fullSize = imageData.ou
			infoUri = imageData.ru
			height = imageData.oh
			width = imageData.ow
			thumbnail = imageData.tu
			
			results.Add(thumbnail, title, infoUri, width, height, fullSize);


	def RetrieveFullSizeImage(fullSizeCallbackParameter):
		return fullSizeCallbackParameter

class ImageData:
		public pt as string
		public ou as string
		public ru as string
		public oh as int
		public ow as int
		public tu as string
