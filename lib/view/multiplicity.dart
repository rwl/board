part of graph.view;

//import java.util.Collection;
//import java.util.Iterator;

//import org.w3c.dom.Element;

class Multiplicity
{

	/**
	 * Defines the type of the source or target terminal. The type is a string
	 * passed to Utils.isNode together with the source or target vertex
	 * value as the first argument.
	 */
	String _type;

	/**
	 * Optional string that specifies the attributename to be passed to
	 * Cell.is to check if the rule applies to a cell.
	 */
	String _attr;

	/**
	 * Optional string that specifies the value of the attribute to be passed
	 * to Cell.is to check if the rule applies to a cell.
	 */
	String _value;

	/**
	 * Boolean that specifies if the rule is applied to the source or target
	 * terminal of an edge.
	 */
	bool _source;

	/**
	 * Defines the minimum number of connections for which this rule applies.
	 * Default is 0.
	 */
	int _min = 0;

	/**
	 * Defines the maximum number of connections for which this rule applies.
	 * A value of 'n' means unlimited times. Default is 'n'. 
	 */
	String _max = "n";

	/**
	 * Holds an array of strings that specify the type of neighbor for which
	 * this rule applies. The strings are used in Cell.is on the opposite
	 * terminal to check if the rule applies to the connection.
	 */
	Collection<String> _validNeighbors;

	/**
	 * Boolean indicating if the list of validNeighbors are those that are allowed
	 * for this rule or those that are not allowed for this rule.
	 */
	bool _validNeighborsAllowed = true;

	/**
	 * Holds the localized error message to be displayed if the number of
	 * connections for which the rule applies is smaller than min or greater
	 * than max.
	 */
	String _countError;

	/**
	 * Holds the localized error message to be displayed if the type of the
	 * neighbor for a connection does not match the rule.
	 */
	String _typeError;

	/**
	 * 
	 */
	Multiplicity(bool source, String type, String attr,
			String value, int min, String max,
			Collection<String> validNeighbors, String countError,
			String typeError, bool validNeighborsAllowed)
	{
		this._source = source;
		this._type = type;
		this._attr = attr;
		this._value = value;
		this._min = min;
		this._max = max;
		this._validNeighbors = validNeighbors;
		this._countError = countError;
		this._typeError = typeError;
		this._validNeighborsAllowed = validNeighborsAllowed;
	}

	/**
	 * Function: check
	 * 
	 * Checks the multiplicity for the given arguments and returns the error
	 * for the given connection or null if the multiplicity does not apply.
	 *  
	 * Parameters:
	 * 
	 * graph - Reference to the enclosing graph instance.
	 * edge - Cell that represents the edge to validate.
	 * source - Cell that represents the source terminal.
	 * target - Cell that represents the target terminal.
	 * sourceOut - Number of outgoing edges from the source terminal.
	 * targetIn - Number of incoming edges for the target terminal.
	 */
	String check(Graph graph, Object edge, Object source,
			Object target, int sourceOut, int targetIn)
	{
		StringBuffer error = new StringBuffer();

		if ((this._source && checkTerminal(graph, source, edge))
				|| (!this._source && checkTerminal(graph, target, edge)))
		{
			if (!isUnlimited())
			{
				int m = getMaxValue();

				if (m == 0 || (this._source && sourceOut >= m)
						|| (!this._source && targetIn >= m))
				{
					error.append(_countError + "\n");
				}
			}

			if (_validNeighbors != null && _typeError != null && _validNeighbors.size() > 0)
			{
				bool isValid = checkNeighbors(graph, edge, source, target);

				if (!isValid)
				{
					error.append(_typeError + "\n");
				}
			}
		}

		return (error.length() > 0) ? error.toString() : null;
	}

	/**
	 * Checks the type of the given value.
	 */
	bool checkNeighbors(Graph graph, Object edge, Object source,
			Object target)
	{
		IGraphModel model = graph.getModel();
		Object sourceValue = model.getValue(source);
		Object targetValue = model.getValue(target);
		bool isValid = !_validNeighborsAllowed;
		Iterator<String> it = _validNeighbors.iterator();

		while (it.hasNext())
		{
			String tmp = it.next();

			if (this._source && checkType(graph, targetValue, tmp))
			{
				isValid = _validNeighborsAllowed;
				break;
			}
			else if (!this._source && checkType(graph, sourceValue, tmp))
			{
				isValid = _validNeighborsAllowed;
				break;
			}
		}

		return isValid;
	}

	/**
	 * Checks the type of the given value.
	 */
	bool checkTerminal(Graph graph, Object terminal, Object edge)
	{
		Object userObject = graph.getModel().getValue(terminal);

		return checkType(graph, userObject, _type, _attr, _value);
	}

	/**
	 * Checks the type of the given value.
	 */
	bool checkType(Graph graph, Object value, String type)
	{
		return checkType(graph, value, type, null, null);
	}

	/**
	 * Checks the type of the given value.
	 */
	bool checkType(Graph graph, Object value, String type,
			String attr, String attrValue)
	{
		if (value != null)
		{
			if (value is Element)
			{
				return Utils.isNode(value, type, attr, attrValue);
			}
			else
			{
				return value.equals(type);
			}
		}

		return false;
	}

	/**
	 * Returns true if max is "n" (unlimited).
	 */
	bool isUnlimited()
	{
		return _max == null || _max == "n";
	}

	/**
	 * Returns the numeric value of max.
	 */
	int getMaxValue()
	{
		try
		{
			return Integer.parseInt(_max);
		}
		on NumberFormatException catch (e)
		{
			// ignore
		}

		return 0;
	}

}
