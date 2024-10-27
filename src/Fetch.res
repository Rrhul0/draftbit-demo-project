module Response = {
  type t

  @send
  external json: t => Js.Promise.t<Js.Json.t> = "json"

  @send
  external text: t => Js.Promise.t<string> = "text"

  @get
  external ok: t => bool = "ok"

  @get
  external status: t => int = "status"

  @get
  external statusText: t => string = "statusText"
}

type method = [#GET|#POST|#PUT|#DELETE]

type options = {
  headers: Js.Dict.t<string>,
  method: method,
  body: option<string>
}

@val
external fetch: (string, option<options>) => promise<Response.t> = "fetch"

let fetchJson = async (~options=?, url: string,): Js.Promise.t<Js.Json.t> =>{
  let response = await fetch(url, options)
  if !Response.ok(response) {
    let text = await response->Response.text
    let msg = `${response->Response.status->Belt.Int.toString} ${response->Response.statusText}: ${text}`
    Js.Exn.raiseError(msg)
  } else {
    response->Response.json
  }
}