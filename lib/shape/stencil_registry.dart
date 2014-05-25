part of graph.shape;

//import java.util.HashMap;
//import java.util.Map;

class StencilRegistry
{
	/**
	 * 
	 */
	static Map<String, Stencil> _stencils = new HashMap<String, Stencil>();

	/**
	 * Adds the given stencil.
	 */
	static void addStencil(String name, Stencil stencil)
	{
		_stencils.put(name, stencil);
	}

	/**
	 * Returns the stencil for the given name.
	 */
	static Stencil getStencil(String name)
	{
		return _stencils.get(name);
	}

}