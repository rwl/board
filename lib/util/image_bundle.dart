/**
 * Copyright (c) 2010, Gaudenz Alder
 */
part of graph.util;

//import java.util.Hashtable;
//import java.util.Map;

/**
 * Maps from keys to base64 encoded images or file locations. All values must
 * be URLs or use the format data:image/format followed by a comma and the base64
 * encoded image data, eg. "data:image/gif,XYZ", where XYZ is the base64 encoded
 * image data.
 * 
 * To add a new image bundle to an existing graph, the following code is used:
 * 
 * <code>
 * ImageBundle bundle = new ImageBundle();
 * bundle.PutImage("myImage", "data:image/gif,R0lGODlhEAAQAMIGAAAAAICAAICAgP" +
 *    "//AOzp2O3r2////////yH+FUNyZWF0ZWQgd2l0aCBUaGUgR0lNUAAh+QQBCgAHACwAAAAA" +
 *    "EAAQAAADTXi63AowynnAMDfjPUDlnAAJhmeBFxAEloliKltWmiYCQvfVr6lBPB1ggxN1hi" +
 *    "laSSASFQpIV5HJBDyHpqK2ejVRm2AAgZCdmCGO9CIBADs=");
 * graph.addImageBundle(bundle);
 * </code>
 * 
 * The image can then be referenced in any cell style using image=myImage.
 * If you are using mxOutline, you should use the same image bundles in the
 * graph that renders the outline.
 * 
 * To convert a given BufferedImage to a base64 encoded String, the following
 * code can be used:
 * 
 * <code>
 * ByteArrayOutputStream bos = new ByteArrayOutputStream();
 * ImageIO.write(image, "png", bos);
 * System.out.println("base64=" + Base64.encodeToString(
 * 	 bos.toByteArray(), false));
 * </code>
 * 
 * The value is decoded in Utils.loadImage. The keys for images are resolved
 * and the short format above is converted to a data URI in
 * Graph.postProcessCellStyle.
 */
class ImageBundle
{

	/**
	 * Maps from keys to images.
	 */
	Map<String, String> _images = new Hashtable<String, String>();

	/**
	 * Returns the images.
	 */
	Map<String, String> getImages()
	{
		return _images;
	}

	/**
	 * Adds the specified entry to the map.
	 */
	void putImage(String key, String value)
	{
		_images[key] = value;
	}

	/**
	 * Returns the value for the given key.
	 */
	String getImage(String key)
	{
		if (key != null)
		{
			return _images[key];
		}
		
		return null;
	}

}
