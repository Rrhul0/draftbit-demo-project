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
  @react.component
  let make = (~styleValue:string,~style:allAomponentStyles) => {
    let (inputValue:string,setInputValue) = React.useState(() => styleValue)

    let onChange = (evt) => {
      evt -> ReactEvent.Form.preventDefault
      let value = (evt->ReactEvent.Form.target)["value"]
      setInputValue(_ => value);
    }

    let isUpdatedValue = styleValue===""?"":"updated"

    <div className="ValueBox" id={style :> string}>
      <input className={"ValueBox-input "++ isUpdatedValue} type_="text" value={inputValue} placeholder={"auto"} onChange={onChange}/>
    </div>
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

  React.useEffect1(() => {
    fetchStyles()|>ignore
    None
  }, [])

  let marginBoxes = switch styles {
    | Some(styles) =>
      <>
        <ValueBox styleValue={styles.marginLeft} style={#marginLeft} />
        <ValueBox styleValue={styles.marginRight} style={#marginRight} />
        <ValueBox styleValue={styles.marginTop} style={#marginTop} />
        <ValueBox styleValue={styles.marginBottom} style={#marginBottom} />
      </>
    | None => React.string("")
  }

  let paddingBoxes = switch styles {
  | Some(styles) =>
    <>
      <ValueBox styleValue={styles.paddingLeft} style={#paddingLeft} />
      <ValueBox styleValue={styles.paddingRight} style={#paddingRight} />
      <ValueBox styleValue={styles.paddingTop} style={#paddingTop} />
      <ValueBox styleValue={styles.paddingBottom} style={#paddingBottom} />
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