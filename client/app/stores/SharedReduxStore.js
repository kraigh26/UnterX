import { combineReducers, applyMiddleware, createStore } from 'redux';
import middleware from 'redux-thunk';

import reducers from '../reducers/reducersIndex';

/*
 *  Export a function that takes the props and returns a Redux store
 *  This is used so that 2 components can have the same store.
 *
 *  The base for this file is copied from:
 *  https://github.com/shakacode/react_on_rails/blob/c2b85c9ef12ece4b8eaaeb448f4d45c1e7ac3223/spec/dummy/client/app/stores/SharedReduxStore.jsx
 */

const shouldLoadInitialToken = function shouldLoadInitialToken({ authToken, loadingToken }) {
  return !authToken && !loadingToken;
}

const loadToken = function loadToken(dispatch) {
  debugger;
  dispatch({type: "HARMONY::AUTH_TOKEN::LOADING"})

  setTimeout(function() {
    debugger;
    dispatch({type: "HARMONY::AUTH_TOKEN::LOADED", payload: {
      authToken: (new Date).toString(),
      expiresIn: 10
    }});

    setTimeout(function() {
      debugger;
      dispatch(loadAction());
    }, 10 * 1000)
  }, 5000);
}

const loadAction = function loadAction() {
  return loadToken;
}

const initialLoadAction = function initialLoadAction() {
  return function (dispatch, getState) {
    const state = getState().harmony;

    if (shouldLoadInitialToken(state)) {
      loadToken(dispatch);
    }
  }
};

export default (props) => {
  const combinedReducer = combineReducers(reducers);

  const store = applyMiddleware(middleware)(createStore)(combinedReducer, props);

  store.dispatch(initialLoadAction())

  return store;
};
