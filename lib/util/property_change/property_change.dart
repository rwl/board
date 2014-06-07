/*
 *  Licensed to the Apache Software Foundation (ASF) under one or more
 *  contributor license agreements.  See the NOTICE file distributed with
 *  this work for additional information regarding copyright ownership.
 *  The ASF licenses this file to You under the Apache License, Version 2.0
 *  (the "License"); you may not use this file except in compliance with
 *  the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
library graph.util.property_change;

class PropertyChangeEvent {
  Object source;
  String propertyName;
  Object oldValue;
  Object newValue;
  PropertyChangeEvent(this.source, this.propertyName, this.oldValue, this.newValue);
}

typedef void PropertyChangeListener(PropertyChangeEvent event);


class PropertyChangeSupport {

  List<PropertyChangeListener> globalListeners = new List<PropertyChangeListener>();

  Map<String, PropertyChangeSupport> children = new Map<String, PropertyChangeSupport>();

  Object source;

  PropertyChangeSupport(this.source);

  void addPropertyChangeListener(PropertyChangeListener listener, [String propertyName = null]) {
    if (listener != null) {
      if (propertyName != null) {
        PropertyChangeSupport listeners = children[propertyName];

        if (listeners == null) {
          listeners = new PropertyChangeSupport(source);
          children[propertyName] = listeners;
        }
        listeners.addPropertyChangeListener(listener);
      } else {
        globalListeners.add(listener);
      }
    }
  }

  void removePropertyChangeListener(PropertyChangeListener listener, [String propertyName = null]) {
    if (listener != null) {
      if (propertyName != null) {
        PropertyChangeSupport listeners = children[propertyName];

        if (listeners != null) {
          listeners.removePropertyChangeListener(listener);
        }
      } else {
        globalListeners.remove(listener);
      }
    }
  }

  void firePropertyChange(String propertyName, Object oldValue, Object newValue) {
    PropertyChangeEvent event = new PropertyChangeEvent(source, propertyName, oldValue, newValue);
    firePropertyChangeEvent(event);
  }

  void firePropertyChangeEvent(PropertyChangeEvent event) {
    Object oldValue = event.oldValue;
    Object newValue = event.newValue;
    if (oldValue != null && newValue != null && oldValue == newValue) {
      return;
    }

    // Collect up the global listeners.
    List<PropertyChangeListener> gListeners = new List<PropertyChangeListener>.from(globalListeners);

    // Fire the events for global listeners.
    for (int i = 0; i < gListeners.length; i++) {
      gListeners[i](event);
    }

    // Fire the events for the property specific listeners if any.
    if (event.propertyName != null) {
      PropertyChangeSupport namedListener = children[event.propertyName];
      if (namedListener != null) {
        namedListener.firePropertyChangeEvent(event);
      }
    }

  }
}
