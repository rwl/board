part of graph.shape;


class StencilRegistry {
  static Map<String, Stencil> _stencils = new HashMap<String, Stencil>();

  /**
   * Adds the given stencil.
   */
  static void addStencil(String name, Stencil stencil) {
    _stencils[name] = stencil;
  }

  /**
   * Returns the stencil for the given name.
   */
  static Stencil getStencil(String name) {
    return _stencils[name];
  }

}
