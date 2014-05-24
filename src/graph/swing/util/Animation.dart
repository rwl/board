/**
 * Copyright (c) 2007, Gaudenz Alder
 */
part of graph.swing.util;

//import graph.util.Event;
//import graph.util.EventObj;
//import graph.util.EventSource;

//import java.awt.event.ActionEvent;
//import java.awt.event.ActionListener;

//import javax.swing.Timer;

/**
 * Baseclass for all timer-based animations. Fires Event.DONE when the
 * stopAnimation method is called. Implement updateAnimation for the
 * actual animation or listen to Event.EXECUTE.
 */
public class Animation extends EventSource
{
	/**
	 * Specifies the default delay for animations in ms. Default is 20.
	 */
	public static int DEFAULT_DELAY = 20;

	/**
	 * Default is DEFAULT_DELAY.
	 */
	protected int _delay;

	/**
	 * Time instance that is used for timing the animation.
	 */
	protected Timer _timer;

	/**
	 * Constructs a new animation instance with the given repaint delay.
	 */
	public Animation()
	{
		this(DEFAULT_DELAY);
	}

	/**
	 * Constructs a new animation instance with the given repaint delay.
	 */
	public Animation(int delay)
	{
		this._delay = delay;
	}

	/**
	 * Returns the delay for the animation.
	 */
	public int getDelay()
	{
		return _delay;
	}

	/**
	 * Sets the delay for the animation.
	 */
	public void setDelay(int value)
	{
		_delay = value;
	}
	
	/**
	 * Returns true if the animation is running.
	 */
	public boolean isRunning()
	{
		return _timer != null;
	}

	/**
	 * Starts the animation by repeatedly invoking updateAnimation.
	 */
	public void startAnimation()
	{
		if (_timer == null)
		{
			_timer = new Timer(_delay, new ActionListener()
			{

				public void actionPerformed(ActionEvent e)
				{
					updateAnimation();
				}

			});

			_timer.start();
		}
	}

	/**
	 * Hook for subclassers to implement the animation. Invoke stopAnimation
	 * when finished, startAnimation to resume. This is called whenever the
	 * timer fires and fires an Event.EXECUTE event with no properties.
	 */
	public void updateAnimation()
	{
		fireEvent(new EventObj(Event.EXECUTE));
	}

	/**
	 * Stops the animation by deleting the timer and fires Event.DONE.
	 */
	public void stopAnimation()
	{
		if (_timer != null)
		{
			_timer.stop();
			_timer = null;
			fireEvent(new EventObj(Event.DONE));
		}
	}

}
