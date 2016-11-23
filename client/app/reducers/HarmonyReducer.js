const initialState = function initialState() {
  return {
    authToken: null,
    expiresIn: null,
    loadingToken: false,
  }
}

export default function(state = initialState(), action) {
  console.log(action)
  console.log(state)

  const { type, payload } = action
  debugger;
  switch (type) {
    case "HARMONY::AUTH_TOKEN::RELOAD":
    case "HARMONY::AUTH_TOKEN::LOADING":
      return Object.assign({}, state, { loadingToken: true });
    case "HARMONY::AUTH_TOKEN::LOADED":
      return Object.assign({}, state, payload, { loadingToken: false });
    case "HARMONY::AUTH_TOKEN::ERROR":
      return state;
    default:
      return state;
  }
}
