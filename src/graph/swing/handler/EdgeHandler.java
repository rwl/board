/**
 * $Id: EdgeHandler.java,v 1.1 2012/11/15 13:26:44 gaudenz Exp $
 * Copyright (c) 2008-2012, JGraph Ltd
 */
package graph.swing.handler;

import graph.model.Geometry;
import graph.model.IGraphModel;
import graph.swing.GraphComponent;
import graph.swing.util.SwingConstants;
import graph.util.Constants;
import graph.util.Point2d;
import graph.view.CellState;
import graph.view.ConnectionConstraint;
import graph.view.Graph;
import graph.view.GraphView;

import java.awt.Color;
import java.awt.Cursor;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.Point;
import java.awt.Rectangle;
import java.awt.Stroke;
import java.awt.event.MouseEvent;
import java.awt.geom.Line2D;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import javax.swing.JComponent;
import javax.swing.JOptionPane;
import javax.swing.JPanel;

/**
 *
 */
public class EdgeHandler extends CellHandler
{
	/**
	 * 
	 */
	protected boolean _cloneEnabled = true;

	/**
	 * 
	 */
	protected Point[] _p;

	/**
	 * 
	 */
	protected transient String _error;

	/**
	 * Workaround for alt-key-state not correct in mouseReleased.
	 */
	protected transient boolean _gridEnabledEvent = false;

	/**
	 * Workaround for shift-key-state not correct in mouseReleased.
	 */
	protected transient boolean _constrainedEvent = false;

	/**
	 * 
	 */
	protected CellMarker _marker = new CellMarker(_graphComponent)
	{

		/**
		 * 
		 */
		private static final long serialVersionUID = 8826073441093831764L;

		// Only returns edges if they are connectable and never returns
		// the edge that is currently being modified
		protected Object _getCell(MouseEvent e)
		{
			Graph graph = _graphComponent.getGraph();
			IGraphModel model = graph.getModel();
			Object cell = super._getCell(e);

			if (cell == EdgeHandler.this._state.getCell()
					|| (!graph.isConnectableEdges() && model.isEdge(cell)))
			{
				cell = null;
			}

			return cell;
		}

		// Sets the highlight color according to isValidConnection
		protected boolean _isValidState(CellState state)
		{
			GraphView view = _graphComponent.getGraph().getView();
			IGraphModel model = _graphComponent.getGraph().getModel();
			Object edge = EdgeHandler.this._state.getCell();
			boolean isSource = isSource(_index);

			CellState other = view
					.getTerminalPort(state,
							view.getState(model.getTerminal(edge, !isSource)),
							!isSource);
			Object otherCell = (other != null) ? other.getCell() : null;
			Object source = (isSource) ? state.getCell() : otherCell;
			Object target = (isSource) ? otherCell : state.getCell();

			_error = validateConnection(source, target);

			return _error == null;
		}

	};

	/**
	 * 
	 * @param graphComponent
	 * @param state
	 */
	public EdgeHandler(GraphComponent graphComponent, CellState state)
	{
		super(graphComponent, state);
	}

	/**
	 * 
	 */
	public void setCloneEnabled(boolean cloneEnabled)
	{
		this._cloneEnabled = cloneEnabled;
	}

	/**
	 * 
	 */
	public boolean isCloneEnabled()
	{
		return _cloneEnabled;
	}

	/**
	 * No flip event is ignored.
	 */
	protected boolean _isIgnoredEvent(MouseEvent e)
	{
		return !_isFlipEvent(e) && super._isIgnoredEvent(e);
	}

	/**
	 * 
	 */
	protected boolean _isFlipEvent(MouseEvent e)
	{
		return false;
	}

	/**
	 * Returns the error message or an empty string if the connection for the
	 * given source target pair is not valid. Otherwise it returns null.
	 */
	public String validateConnection(Object source, Object target)
	{
		return _graphComponent.getGraph().getEdgeValidationError(
				_state.getCell(), source, target);
	}

	/**
	 * Returns true if the current index is 0.
	 */
	public boolean isSource(int index)
	{
		return index == 0;
	}

	/**
	 * Returns true if the current index is the last index.
	 */
	public boolean isTarget(int index)
	{
		return index == _getHandleCount() - 2;
	}

	/**
	 * Hides the middle handle if the edge is not bendable.
	 */
	protected boolean _isHandleVisible(int index)
	{
		return super._isHandleVisible(index)
				&& (isSource(index) || isTarget(index) || _isCellBendable());
	}

	/**
	 * 
	 */
	protected boolean _isCellBendable()
	{
		return _graphComponent.getGraph().isCellBendable(_state.getCell());
	}

	/**
	 * 
	 */
	protected Rectangle[] _createHandles()
	{
		_p = _createPoints(_state);
		Rectangle[] h = new Rectangle[_p.length + 1];

		for (int i = 0; i < h.length - 1; i++)
		{
			h[i] = _createHandle(_p[i]);
		}

		h[_p.length] = _createHandle(_state.getAbsoluteOffset().getPoint(),
				Constants.LABEL_HANDLE_SIZE);

		return h;
	}

	/**
	 * 
	 */
	protected Color _getHandleFillColor(int index)
	{
		boolean source = isSource(index);

		if (source || isTarget(index))
		{
			Graph graph = _graphComponent.getGraph();
			Object terminal = graph.getModel().getTerminal(_state.getCell(),
					source);

			if (terminal == null
					&& !_graphComponent.getGraph().isTerminalPointMovable(
							_state.getCell(), source))
			{
				return SwingConstants.LOCKED_HANDLE_FILLCOLOR;
			}
			else if (terminal != null)
			{
				return (_graphComponent.getGraph().isCellDisconnectable(
						_state.getCell(), terminal, source)) ? SwingConstants.CONNECT_HANDLE_FILLCOLOR
						: SwingConstants.LOCKED_HANDLE_FILLCOLOR;
			}
		}

		return super._getHandleFillColor(index);
	}

	/**
	 * 
	 * @param x
	 * @param y
	 * @return Returns the inde of the handle at the given location.
	 */
	public int getIndexAt(int x, int y)
	{
		int index = super.getIndexAt(x, y);

		// Makes the complete label a trigger for the label handle
		if (index < 0 && _handles != null && _handlesVisible && isLabelMovable()
				&& _state.getLabelBounds().getRectangle().contains(x, y))
		{
			index = _handles.length - 1;
		}

		return index;
	}

	/**
	 * 
	 */
	protected Rectangle _createHandle(Point center)
	{
		return _createHandle(center, Constants.HANDLE_SIZE);
	}

	/**
	 * 
	 */
	protected Rectangle _createHandle(Point center, int size)
	{
		return new Rectangle(center.x - size / 2, center.y - size / 2, size,
				size);
	}

	/**
	 * 
	 */
	protected Point[] _createPoints(CellState s)
	{
		Point[] pts = new Point[s.getAbsolutePointCount()];

		for (int i = 0; i < pts.length; i++)
		{
			pts[i] = s.getAbsolutePoint(i).getPoint();
		}

		return pts;
	}

	/**
	 * 
	 */
	protected JComponent _createPreview()
	{
		JPanel preview = new JPanel()
		{
			/**
			 * 
			 */
			private static final long serialVersionUID = -894546588972313020L;

			public void paint(Graphics g)
			{
				super.paint(g);

				if (!isLabel(_index) && _p != null)
				{
					((Graphics2D) g).setStroke(SwingConstants.PREVIEW_STROKE);

					if (isSource(_index) || isTarget(_index))
					{
						if (_marker.hasValidState()
								|| _graphComponent.getGraph()
										.isAllowDanglingEdges())
						{
							g.setColor(SwingConstants.DEFAULT_VALID_COLOR);
						}
						else
						{
							g.setColor(SwingConstants.DEFAULT_INVALID_COLOR);
						}
					}
					else
					{
						g.setColor(Color.BLACK);
					}

					Point origin = getLocation();
					Point last = _p[0];

					for (int i = 1; i < _p.length; i++)
					{
						g.drawLine(last.x - origin.x, last.y - origin.y, _p[i].x
								- origin.x, _p[i].y - origin.y);
						last = _p[i];
					}
				}
			}
		};

		if (isLabel(_index))
		{
			preview.setBorder(SwingConstants.PREVIEW_BORDER);
		}

		preview.setOpaque(false);
		preview.setVisible(false);

		return preview;
	}

	/**
	 * 
	 * @param point
	 * @param gridEnabled
	 * @return Returns the scaled, translated and grid-aligned point.
	 */
	protected Point2d _convertPoint(Point2d point, boolean gridEnabled)
	{
		Graph graph = _graphComponent.getGraph();
		double scale = graph.getView().getScale();
		Point2d trans = graph.getView().getTranslate();
		double x = point.getX() / scale - trans.getX();
		double y = point.getY() / scale - trans.getY();

		if (gridEnabled)
		{
			x = graph.snap(x);
			y = graph.snap(y);
		}

		point.setX(x - _state.getOrigin().getX());
		point.setY(y - _state.getOrigin().getY());

		return point;
	}

	/**
	 * 
	 * @return Returns the bounds of the preview.
	 */
	protected Rectangle _getPreviewBounds()
	{
		Rectangle bounds = null;

		if (isLabel(_index))
		{
			bounds = _state.getLabelBounds().getRectangle();
		}
		else
		{
			bounds = new Rectangle(_p[0]);

			for (int i = 0; i < _p.length; i++)
			{
				bounds.add(_p[i]);
			}

			bounds.height += 1;
			bounds.width += 1;
		}

		return bounds;
	}

	/**
	 * 
	 */
	public void mousePressed(MouseEvent e)
	{
		super.mousePressed(e);

		boolean source = isSource(_index);

		if (source || isTarget(_index))
		{
			Graph graph = _graphComponent.getGraph();
			IGraphModel model = graph.getModel();
			Object terminal = model.getTerminal(_state.getCell(), source);

			if ((terminal == null && !graph.isTerminalPointMovable(
					_state.getCell(), source))
					|| (terminal != null && !graph.isCellDisconnectable(
							_state.getCell(), terminal, source)))
			{
				_first = null;
			}
		}
	}

	/**
	 * 
	 */
	public void mouseDragged(MouseEvent e)
	{
		if (!e.isConsumed() && _first != null)
		{
			_gridEnabledEvent = _graphComponent.isGridEnabledEvent(e);
			_constrainedEvent = _graphComponent.isConstrainedEvent(e);

			boolean isSource = isSource(_index);
			boolean isTarget = isTarget(_index);

			Object source = null;
			Object target = null;

			if (isLabel(_index))
			{
				Point2d abs = _state.getAbsoluteOffset();
				double dx = abs.getX() - _first.x;
				double dy = abs.getY() - _first.y;

				Point2d pt = new Point2d(e.getPoint());

				if (_gridEnabledEvent)
				{
					pt = _graphComponent.snapScaledPoint(pt, dx, dy);
				}

				if (_constrainedEvent)
				{
					if (Math.abs(e.getX() - _first.x) > Math.abs(e.getY()
							- _first.y))
					{
						pt.setY(abs.getY());
					}
					else
					{
						pt.setX(abs.getX());
					}
				}

				Rectangle rect = _getPreviewBounds();
				rect.translate((int) Math.round(pt.getX() - _first.x),
						(int) Math.round(pt.getY() - _first.y));
				_preview.setBounds(rect);
			}
			else
			{
				// Clones the cell state and updates the absolute points using
				// the current state of this handle. This is required for
				// computing the correct perimeter points and edge style.
				Geometry geometry = _graphComponent.getGraph()
						.getCellGeometry(_state.getCell());
				CellState clone = (CellState) _state.clone();
				List<Point2d> points = geometry.getPoints();
				GraphView view = clone.getView();

				if (isSource || isTarget)
				{
					_marker.process(e);
					CellState currentState = _marker.getValidState();
					target = _state.getVisibleTerminal(!isSource);

					if (currentState != null)
					{
						source = currentState.getCell();
					}
					else
					{
						Point2d pt = new Point2d(e.getPoint());

						if (_gridEnabledEvent)
						{
							pt = _graphComponent.snapScaledPoint(pt);
						}

						clone.setAbsoluteTerminalPoint(pt, isSource);
					}

					if (!isSource)
					{
						Object tmp = source;
						source = target;
						target = tmp;
					}
				}
				else
				{
					Point2d point = _convertPoint(new Point2d(e.getPoint()),
							_gridEnabledEvent);

					if (points == null)
					{
						points = Arrays.asList(new Point2d[] { point });
					}
					else if (_index - 1 < points.size())
					{
						points = new ArrayList<Point2d>(points);
						points.set(_index - 1, point);
					}

					source = view.getVisibleTerminal(_state.getCell(), true);
					target = view.getVisibleTerminal(_state.getCell(), false);
				}

				// Computes the points for the edge style and terminals
				CellState sourceState = view.getState(source);
				CellState targetState = view.getState(target);

				ConnectionConstraint sourceConstraint = _graphComponent
						.getGraph().getConnectionConstraint(clone, sourceState,
								true);
				ConnectionConstraint targetConstraint = _graphComponent
						.getGraph().getConnectionConstraint(clone, targetState,
								false);

				/* TODO: Implement mxConstraintHandler
				ConnectionConstraint constraint = constraintHandler.currentConstraint;

				if (constraint == null)
				{
					constraint = new ConnectionConstraint();
				}
				
				if (isSource)
				{
					sourceConstraint = constraint;
				}
				else if (isTarget)
				{
					targetConstraint = constraint;
				}
				*/

				if (!isSource || sourceState != null)
				{
					view.updateFixedTerminalPoint(clone, sourceState, true,
							sourceConstraint);
				}

				if (!isTarget || targetState != null)
				{
					view.updateFixedTerminalPoint(clone, targetState, false,
							targetConstraint);
				}

				view.updatePoints(clone, points, sourceState, targetState);
				view.updateFloatingTerminalPoints(clone, sourceState,
						targetState);

				// Uses the updated points from the cloned state to draw the preview
				_p = _createPoints(clone);
				_preview.setBounds(_getPreviewBounds());
			}

			if (!_preview.isVisible()
					&& _graphComponent.isSignificant(e.getX() - _first.x,
							e.getY() - _first.y))
			{
				_preview.setVisible(true);
			}
			else if (_preview.isVisible())
			{
				_preview.repaint();
			}

			e.consume();
		}
	}

	/**
	 * 
	 */
	public void mouseReleased(MouseEvent e)
	{
		Graph graph = _graphComponent.getGraph();

		if (!e.isConsumed() && _first != null)
		{
			double dx = e.getX() - _first.x;
			double dy = e.getY() - _first.y;

			if (_graphComponent.isSignificant(dx, dy))
			{
				if (_error != null)
				{
					if (_error.length() > 0)
					{
						JOptionPane.showMessageDialog(_graphComponent, _error);
					}
				}
				else if (isLabel(_index))
				{
					Point2d abs = _state.getAbsoluteOffset();
					dx = abs.getX() - _first.x;
					dy = abs.getY() - _first.y;

					Point2d pt = new Point2d(e.getPoint());

					if (_gridEnabledEvent)
					{
						pt = _graphComponent.snapScaledPoint(pt, dx, dy);
					}

					if (_constrainedEvent)
					{
						if (Math.abs(e.getX() - _first.x) > Math.abs(e.getY()
								- _first.y))
						{
							pt.setY(abs.getY());
						}
						else
						{
							pt.setX(abs.getX());
						}
					}

					_moveLabelTo(_state, pt.getX() + dx, pt.getY() + dy);
				}
				else if (_marker.hasValidState()
						&& (isSource(_index) || isTarget(_index)))
				{
					_connect(_state.getCell(), _marker.getValidState().getCell(),
							isSource(_index), _graphComponent.isCloneEvent(e)
									&& isCloneEnabled());
				}
				else if ((!isSource(_index) && !isTarget(_index))
						|| _graphComponent.getGraph().isAllowDanglingEdges())
				{
					_movePoint(
							_state.getCell(),
							_index,
							_convertPoint(new Point2d(e.getPoint()),
									_gridEnabledEvent));
				}

				e.consume();
			}
		}

		if (!e.isConsumed() && _isFlipEvent(e))
		{
			graph.flipEdge(_state.getCell());
			e.consume();
		}

		super.mouseReleased(e);
	}

	/**
	 * Extends the implementation to reset the current error and marker.
	 */
	public void reset()
	{
		super.reset();

		_marker.reset();
		_error = null;
	}

	/**
	 * Moves the edges control point with the given index to the given point.
	 */
	protected void _movePoint(Object edge, int pointIndex, Point2d point)
	{
		IGraphModel model = _graphComponent.getGraph().getModel();
		Geometry geometry = model.getGeometry(edge);

		if (geometry != null)
		{
			model.beginUpdate();
			try
			{
				geometry = (Geometry) geometry.clone();

				if (isSource(_index) || isTarget(_index))
				{
					_connect(edge, null, isSource(_index), false);
					geometry.setTerminalPoint(point, isSource(_index));
				}
				else
				{
					List<Point2d> pts = geometry.getPoints();

					if (pts == null)
					{
						pts = new ArrayList<Point2d>();
						geometry.setPoints(pts);
					}

					if (pts != null)
					{
						if (pointIndex <= pts.size())
						{
							pts.set(pointIndex - 1, point);
						}
						else if (pointIndex - 1 <= pts.size())
						{
							pts.add(pointIndex - 1, point);
						}
					}
				}

				model.setGeometry(edge, geometry);
			}
			finally
			{
				model.endUpdate();
			}
		}
	}

	/**
	 * Connects the given edge to the given source or target terminal.
	 * 
	 * @param edge
	 * @param terminal
	 * @param isSource
	 */
	protected void _connect(Object edge, Object terminal, boolean isSource,
			boolean isClone)
	{
		Graph graph = _graphComponent.getGraph();
		IGraphModel model = graph.getModel();

		model.beginUpdate();
		try
		{
			if (isClone)
			{
				Object clone = graph.cloneCells(new Object[] { edge })[0];

				Object parent = model.getParent(edge);
				graph.addCells(new Object[] { clone }, parent);

				Object other = model.getTerminal(edge, !isSource);
				graph.connectCell(clone, other, !isSource);

				graph.setSelectionCell(clone);
				edge = clone;
			}

			// Passes an empty constraint to reset constraint information
			graph.connectCell(edge, terminal, isSource,
					new ConnectionConstraint());
		}
		finally
		{
			model.endUpdate();
		}
	}

	/**
	 * Moves the label to the given position.
	 */
	protected void _moveLabelTo(CellState edgeState, double x, double y)
	{
		Graph graph = _graphComponent.getGraph();
		IGraphModel model = graph.getModel();
		Geometry geometry = model.getGeometry(_state.getCell());

		if (geometry != null)
		{
			geometry = (Geometry) geometry.clone();

			// Resets the relative location stored inside the geometry
			Point2d pt = graph.getView().getRelativePoint(edgeState, x, y);
			geometry.setX(pt.getX());
			geometry.setY(pt.getY());

			// Resets the offset inside the geometry to find the offset
			// from the resulting point
			double scale = graph.getView().getScale();
			geometry.setOffset(new Point2d(0, 0));
			pt = graph.getView().getPoint(edgeState, geometry);
			geometry.setOffset(new Point2d(Math.round((x - pt.getX()) / scale),
					Math.round((y - pt.getY()) / scale)));

			model.setGeometry(edgeState.getCell(), geometry);
		}
	}

	/**
	 * 
	 */
	protected Cursor _getCursor(MouseEvent e, int index)
	{
		Cursor cursor = null;

		if (isLabel(index))
		{
			cursor = new Cursor(Cursor.MOVE_CURSOR);
		}
		else
		{
			cursor = new Cursor(Cursor.HAND_CURSOR);
		}

		return cursor;
	}

	/**
	 * 
	 */
	public Color getSelectionColor()
	{
		return SwingConstants.EDGE_SELECTION_COLOR;
	}

	/**
	 * 
	 */
	public Stroke getSelectionStroke()
	{
		return SwingConstants.EDGE_SELECTION_STROKE;
	}

	/**
	 * 
	 */
	public void paint(Graphics g)
	{
		Graphics2D g2 = (Graphics2D) g;

		Stroke stroke = g2.getStroke();
		g2.setStroke(getSelectionStroke());
		g.setColor(getSelectionColor());

		Point last = _state.getAbsolutePoint(0).getPoint();

		for (int i = 1; i < _state.getAbsolutePointCount(); i++)
		{
			Point current = _state.getAbsolutePoint(i).getPoint();
			Line2D line = new Line2D.Float(last.x, last.y, current.x, current.y);

			Rectangle bounds = g2.getStroke().createStrokedShape(line)
					.getBounds();

			if (g.hitClip(bounds.x, bounds.y, bounds.width, bounds.height))
			{
				g2.draw(line);
			}

			last = current;
		}

		g2.setStroke(stroke);
		super.paint(g);
	}

}
