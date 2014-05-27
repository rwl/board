part of graph.analysis;

class StructuralException extends Exception {
    /**
	 * A custom exception for irregular graph structure for certain algorithms
	 */
//	static final long serialVersionUID = -468633497832330356L;

	StructuralException(String message) : super(message);
}
