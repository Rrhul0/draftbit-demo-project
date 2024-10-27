type marginStyles = [#marginTop|#marginRight|#marginBottom|#marginLeft]
type paddingStyles = [#paddingTop|#paddingRight|#paddingBottom|#paddingLeft]
type allAomponentStyles = [marginStyles | paddingStyles]

type componentStyles = {
  marginLeft: string,
  marginRight: string,
  marginTop: string,
  marginBottom: string,
  paddingLeft: string,
  paddingRight: string,
  paddingTop: string,
  paddingBottom: string,
}

module ValueBox = {
  @send external focus: Dom.element => unit = "focus"
  @send external blur: Dom.element => unit = "blur"

  @react.component
  let make = (~styleValue:string,~style:allAomponentStyles,~onChangeValueBlur) => {
    let textInput = React.useRef(Js.Nullable.null)
    let (inputValue:string,setInputValue) = React.useState(() => styleValue)
    
    let onChange = (evt) => {
      evt -> ReactEvent.Form.preventDefault
      let value = (evt->ReactEvent.Form.target)["value"]
      setInputValue(_ => value);
    }

    let onSubmit = (evt) => {
      ReactEvent.Form.preventDefault(evt)
      switch textInput.current{
      | Null|Undefined => ()
      | Value(textInput) => textInput-> blur
      }
    }

    let onBlur = (_) => {
      onChangeValueBlur(~styleName=style,~value=inputValue)
    }

    let isUpdatedValue = styleValue===""?"":"updated"

    <form className="ValueBox" id={style :> string} onSubmit>
      <input className={"ValueBox-input "++ isUpdatedValue} ref={textInput -> ReactDOM.Ref.domRef} type_="text" value={inputValue} placeholder={"auto"} onChange={onChange} onBlur={onBlur}/>
    </form>
  }
}
  

@react.component
let make = () => {
  let (styles: option<componentStyles>, setStyles) = React.useState(_ => None)

  let fetchStyles = async () => {
    let response = await Fetch.fetchJson(`http://localhost:12346/getComponentStyle/1`)
    let stylesGot = Obj.magic(response)
    setStyles(_=>stylesGot)
  }

  let putStyles = async (fetchOptions)=>{
    let response = await Fetch.fetchJson(`http://localhost:12346/setComponentStyle/1`,~options=fetchOptions)
    let stylesGot = Obj.magic(response)
    setStyles(_=>stylesGot)
  }

  React.useEffect1(() => {
    fetchStyles()|>ignore
    None
  }, [])

  let onChangeValueBlur = (~styleName:allAomponentStyles,~value:string) => {
    let body = Js.Json.stringifyAny({
      "styleName":styleName,
      "value":value
    })
    let fetchOptions:Fetch.options = {
      headers:Js.Dict.fromArray([("Content-Type","application/json")]),
      method:#POST,
      body:body
    }
    putStyles(fetchOptions)|>ignore
  }

  let marginBoxes = switch styles {
    | Some(styles) =>
      <>
        <ValueBox styleValue={styles.marginLeft} style={#marginLeft} onChangeValueBlur />
        <ValueBox styleValue={styles.marginRight} style={#marginRight} onChangeValueBlur />
        <ValueBox styleValue={styles.marginTop} style={#marginTop} onChangeValueBlur />
        <ValueBox styleValue={styles.marginBottom} style={#marginBottom} onChangeValueBlur />
      </>
    | None => React.string("")
  }

  let paddingBoxes = switch styles {
    | Some(styles) =>
      <>
      <ValueBox styleValue={styles.paddingLeft} style={#paddingLeft} onChangeValueBlur />
          <ValueBox styleValue={styles.paddingRight} style={#paddingRight} onChangeValueBlur />
          <ValueBox styleValue={styles.paddingTop} style={#paddingTop} onChangeValueBlur />
          <ValueBox styleValue={styles.paddingBottom} style={#paddingBottom} onChangeValueBlur />
        </>
    | None => React.string("")
  }

  <div>
    <div className="Outerbox">
      marginBoxes
      <div className="Innerbox">
        paddingBoxes
      </div>
    </div>
  </div>
}