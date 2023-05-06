# refs: System.Web.Extensions

import System
import System.Text.RegularExpressions
import System.Web.Script.Serialization
import AlbumArtDownloader.Scripts
import util

class Discogs(AlbumArtDownloader.Scripts.IScript):
	def constructor():
		// Discogs requires TLS 1.1 or greater
		Tls12 = Enum.ToObject(typeof(System.Net.SecurityProtocolType), 3072);
		Tls11 = Enum.ToObject(typeof(System.Net.SecurityProtocolType), 768);

		System.Net.ServicePointManager.SecurityProtocol = Tls12 | Tls11 | System.Net.SecurityProtocolType.Tls
	Name as string:
		get: return "Discogs"
	Author as string:
		get: return "Alex Vallat"
	Version as string:
		get: return "0.26"
	def Search(artist as string, album as string, results as IScriptResults):
		//artist = StripCharacters("&.'\";:?!", artist)
		//album = StripCharacters("&.'\";:?!", album)

		json = JavaScriptSerializer()

		resultsInfoJson = GetDiscogsPage("https://www.discogs.com/search/ac?searchType=master&q=" + EncodeUrl("\"${artist}\" \"${album}\""))
		resultsInfo = json.Deserialize[of (Result)](resultsInfoJson)
		
		results.EstimatedCount = resultsInfo.Length;
		
		for result in resultsInfo:
			// Get the release info from api
			title = result.GetString(result.artist) + " - " + result.GetString(result.title);
			url = result.GetString(result.uri);
			//id = url.Substring(url.LastIndexOf('/'));

			releasePage = GetDiscogsPage("https://www.discogs.com" + url)

			releaseImagesUrl = Regex("href=\"(?<url>[^\"]+)\">.*?(?!</a>)More images", RegexOptions.IgnoreCase | RegexOptions.Singleline).Match(releasePage).Groups["url"].Value
			releaseImagesPage = GetDiscogsPage("https://www.discogs.com" + releaseImagesUrl)

			releasePageImagesMatches = Regex("\"Image:{[^{]+\":(?<json>{.+?}})", RegexOptions.IgnoreCase | RegexOptions.Singleline).Matches(releaseImagesPage)
			for match as Match in releasePageImagesMatches:
				imageInfo = json.Deserialize[of ImageInfo](match.Groups["json"].Value)
				if (imageInfo.fullsize != null and imageInfo.thumbnail != null):
					fullInfo = json.Deserialize[of ImageRef](imageInfo.fullsize.__ref.Substring(10))
					thumbInfo = json.Deserialize[of ImageRef](imageInfo.thumbnail.__ref.Substring(10))

					results.Add(thumbInfo.sourceUrl, title, "https://www.discogs.com" + url + "/image/" + imageInfo.id, -1, -1, fullInfo.sourceUrl, CoverType.Unknown)

	def RetrieveFullSizeImage(fullSizeCallbackParameter):
		return GetPageStream(fullSizeCallbackParameter, null, true);

	def GetDiscogsPage(url) as string:
		request = System.Net.HttpWebRequest.Create(url) as System.Net.HttpWebRequest

		request.Accept = "*/*"
		request.UserAgent = "Mozilla/5.0 (AAD on " + System.Environment.MachineName + ")"
		
		try:
			response = request.GetResponse()
		except ex as WebException:
			exResponse = ex.Response as System.Net.HttpWebResponse
			if (exResponse != null and exResponse.StatusCode == 308):
				return GetDiscogsPage(exResponse.GetResponseHeader("Location"))
			raise

		stream = response.GetResponseStream()
		try:
			return GetPage(stream)
		ensure:
			stream.Close()
	
	class Result:
		public artist as object
		public title as object
		public uri as object

		def GetString(value):
			result = value as string;
			if result is null:
				result = (value as (object))[0] as string;
			return result;

	class ImageInfo:
		public id as string
		public thumbnail as ImageRefJson
		public fullsize as ImageRefJson

		class ImageRefJson:
			public __ref as string
	
	class ImageRef:
		public sourceUrl as string