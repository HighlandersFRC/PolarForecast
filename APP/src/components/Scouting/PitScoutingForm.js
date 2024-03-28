import React, { useState, useEffect, useRef } from 'react';
import TextField from '@mui/material/TextField';
import Button from '@mui/material/Button';
import { Autocomplete, ImageList, Switch, ThemeProvider, createTheme } from '@mui/material';
import Header from 'components/Headers/Header';
import { Card, CardHeader, Container, Row } from 'reactstrap';
import { postPitScouting } from 'api';
import { getPitScoutingData } from 'api';
import { useHistory } from 'react-router-dom/cjs/react-router-dom.min';
import Snowfall from 'react-snowfall';
import { ConstructionOutlined } from '@mui/icons-material';

const PitScoutingForm = ({ teamPage }) => {
    const history = useHistory()
    const url = new URL(window.location.href);
    const serverPath = url.pathname.split("/")[0];
    let eventName = url.pathname.split("/")[3] + url.pathname.split("/")[4];
    let year = url.pathname.split("/")[3]
    let eventCode = url.pathname.split("/")[4]
    let team = url.pathname.split("/")[5].replace("team-", "")

    // console.log(eventName, year, eventCode, team)

    const [text, setText] = useState("Submission Failed")
    const [formData, setFormData] = useState({
        event_code: eventName,
        team_number: parseInt(team),
        time: 0,
        data: {
            amp_scoring: false,
            speaker_scoring: false,
            trap_scoring: false,
            can_climb: false,
            can_harmonize: false,
            go_under_stage: false,
            drive_train: "",
            ground_pick_up: false,
            feeder_pick_up: false,
            favorite_color: "",
            autos: [],
        }
    });
    const [containerHeight, setContainerHeight] = useState(`calc(100vh - 200px)`);
    const [showForm, setShowForm] = useState(true)
    const handleChange = async (field, value) => {
        if (typeof (value) === undefined) {
            value = ""
        }
        setFormData((prevData) => {
            const updatedData = { ...prevData };
            const fieldPath = field.split('.');
            let currentField = updatedData;
            for (let i = 0; i < fieldPath.length - 1; i++) {
                currentField = currentField[fieldPath[i]];
            }
            currentField[fieldPath[fieldPath.length - 1]] = value;
            return updatedData
        });
    };

    useEffect(() => {
        // Fetch data only when the component mounts
        if (formData.time === 0) {
            getPitScoutingData(year, eventCode, `frc${team}`, pitScoutingDataCallback);
        }
    }, [formData.time]);

    const handleSubmit = () => {
        // Set the "Time" field to the current UTC timestamp when submitting the form
        setFormData((prevData) => ({
            ...prevData,
            time: Math.floor(new Date().getTime() / 1000), // Current UTC timestamp in seconds
        }));
        postPitScouting(formData, pitScoutingStatusCallback);
        // Handle form submission logic here
    };

    const pitScoutingStatusCallback = (status) => {
        if (status === 200) {
            setShowForm(false)
            setText("Submission Successfull")
        } else {
            setShowForm(false)
            setText("Submission Failed")
        }
    }

    const pitScoutingDataCallback = (value) => {
        if (value !== null && value !== undefined) {
            if (!value.data?.autos) value.data.autos = [];
            // console.log(value)
            setFormData(value)
        }
    }

    const darkTheme = createTheme({
        palette: {
            mode: "dark",
        },
    });

    const changeData = () => {
        setShowForm(true)
    }

    const backToScouting = () => {
        history.push(`../../../event/${year}/${eventCode}#pit-scouting`);
    }

    const RenderSelectablePieces = ({ auto, idx }) => {
        const NOTE_SIZE = 80;
        const fieldImageRef = useRef(null)
        const [fieldImageWidth, setFieldImageWidth] = useState(0);
        const [imageScaleFactor, setImageScaleFactor] = useState(1);
        const [imageLoaded, setImageLoaded] = useState(false)
        const [isFlipped, setIsFlipped] = useState(false);
        useEffect(() => {
            if (fieldImageRef.current) {
                const { naturalWidth, offsetWidth } = fieldImageRef.current;
                setFieldImageWidth(offsetWidth);
                setImageScaleFactor(offsetWidth / naturalWidth);
            }
        }, [imageLoaded]);
        const handlePieceClick = (pieceType) => {
            if (!teamPage) {
                const selectedPieces = [...auto];
                const index = selectedPieces.indexOf(pieceType);
                if (index === -1) {
                    selectedPieces.push(pieceType); // If not selected, add it
                } else {
                    selectedPieces.splice(index, 1); // If already selected, remove it
                }
                setFormData((prevData) => {
                    const newData = {
                        ...prevData,
                        data: {
                            ...prevData.data,
                            autos: [...prevData.data.autos]
                        }
                    }
                    newData.data.autos[idx] = selectedPieces
                    return newData
                });
            }
        };
        const handleImageLoad = () => {
            setImageLoaded(true);
        };
        const calculatePosition = (x, y) => {
            let scaledX = x * imageScaleFactor;
            let scaledY = y * imageScaleFactor;
            if (isFlipped) {
                scaledX = fieldImageWidth - scaledX - (NOTE_SIZE * imageScaleFactor)
            }
            return { left: `${scaledX}px`, top: `${scaledY}px` };
        };
        const deleteAuto = () => {
            setFormData((prevData) => {
                const newData = {
                    ...prevData,
                    data: {
                        ...prevData.data,
                        autos: [...prevData.data.autos]
                    }
                }
                newData.data.autos.splice(idx, 1)
                return newData
            })
        }
        return (
            <>
                <div>
                    <div style={{ position: 'relative', maxWidth: '100%', height: 'auto' }}>
                        {/* Display your field image here */}
                        <img
                            ref={fieldImageRef}
                            src={serverPath + "/AutosGameField.png"}
                            alt="Field"
                            style={{ maxWidth: '100%', height: 'auto' }}
                            onLoad={handleImageLoad}
                        />
                        <img
                            src="/Note.png"
                            style={{
                                position: 'absolute',
                                ...calculatePosition(186, 978),
                                width: `${NOTE_SIZE * imageScaleFactor}px`,
                                height: `${NOTE_SIZE * imageScaleFactor}px`,
                                cursor: !teamPage ? 'pointer' : '',
                                filter: auto.includes('spike_left') ? 'none' : 'grayscale(100%)'
                            }}
                            onClick={() => handlePieceClick('spike_left')}
                        />
                        <img
                            src="/Note.png"
                            style={{
                                position: 'absolute',
                                ...calculatePosition(433, 978),
                                width: `${NOTE_SIZE * imageScaleFactor}px`,
                                height: `${NOTE_SIZE * imageScaleFactor}px`,
                                cursor: !teamPage ? 'pointer' : '',
                                filter: auto.includes('spike_middle') ? 'none' : 'grayscale(100%)'
                            }}
                            onClick={() => handlePieceClick('spike_middle')}
                        />
                        <img
                            src="/Note.png"
                            style={{
                                position: 'absolute',
                                ...calculatePosition(679, 978),
                                width: `${NOTE_SIZE * imageScaleFactor}px`,
                                height: `${NOTE_SIZE * imageScaleFactor}px`,
                                cursor: !teamPage ? 'pointer' : '',
                                filter: auto.includes('spike_right') ? 'none' : 'grayscale(100%)'
                            }}
                            onClick={() => handlePieceClick('spike_right')}
                        />
                        <img
                            src="/Note.png"
                            style={{
                                position: 'absolute',
                                ...calculatePosition(108, 61),
                                width: `${NOTE_SIZE * imageScaleFactor}px`,
                                height: `${NOTE_SIZE * imageScaleFactor}px`,
                                cursor: !teamPage ? 'pointer' : '',
                                filter: auto.includes('halfway_far_left') ? 'none' : 'grayscale(100%)'
                            }}
                            onClick={() => handlePieceClick('halfway_far_left')}
                        />
                        <img
                            src="/Note.png"
                            style={{
                                position: 'absolute',
                                ...calculatePosition(394, 61),
                                width: `${NOTE_SIZE * imageScaleFactor}px`,
                                height: `${NOTE_SIZE * imageScaleFactor}px`,
                                cursor: !teamPage ? 'pointer' : '',
                                filter: auto.includes('halfway_middle_left') ? 'none' : 'grayscale(100%)'
                            }}
                            onClick={() => handlePieceClick('halfway_middle_left')}
                        />
                        <img
                            src="/Note.png"
                            style={{
                                position: 'absolute',
                                ...calculatePosition(679, 61),
                                width: `${NOTE_SIZE * imageScaleFactor}px`,
                                height: `${NOTE_SIZE * imageScaleFactor}px`,
                                cursor: !teamPage ? 'pointer' : '',
                                filter: auto.includes('halfway_middle') ? 'none' : 'grayscale(100%)'
                            }}
                            onClick={() => handlePieceClick('halfway_middle')}
                        />
                        <img
                            src="/Note.png"
                            style={{
                                position: 'absolute',
                                ...calculatePosition(965, 61),
                                width: `${NOTE_SIZE * imageScaleFactor}px`,
                                height: `${NOTE_SIZE * imageScaleFactor}px`,
                                cursor: !teamPage ? 'pointer' : '',
                                filter: auto.includes('halfway_middle_right') ? 'none' : 'grayscale(100%)'
                            }}
                            onClick={() => handlePieceClick('halfway_middle_right')}
                        />
                        <img
                            src="/Note.png"
                            style={{
                                position: 'absolute',
                                ...calculatePosition(1251, 61),
                                width: `${NOTE_SIZE * imageScaleFactor}px`,
                                height: `${NOTE_SIZE * imageScaleFactor}px`,
                                cursor: !teamPage ? 'pointer' : '',
                                filter: auto.includes('halfway_far_right') ? 'none' : 'grayscale(100%)'
                            }}
                            onClick={() => handlePieceClick('halfway_far_right')}
                        />
                    </div>
                    {!teamPage && <Button fullWidth variant="contained" onClick={deleteAuto} sx={{ color: "red" }}>
                        Delete Auto
                    </Button>}
                </div>
            </>
        );
    };

    const addAuto = () => {
        setFormData((prevData) => {
            const newData = {
                ...prevData,
                data: {
                    ...prevData.data,
                    autos: [...prevData.data.autos, []]
                }
            }
            // console.log(newData)
            return newData
        })
    }

    return (<>
        <Card className="polar-box">
            <CardHeader className="bg-transparent">
                <h3 className="text-white mb-0">PitScouting</h3>
            </CardHeader>
            {showForm && <form style={{ display: 'flex', flexDirection: 'column', gap: '16px', padding: '16px' }}>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                    <TextField
                        label="Event Code"
                        value={formData.event_code}
                        onChange={(e) => handleChange('event_code', e.target.value)}
                        disabled // Disable the Event Code field
                    />
                    <TextField
                        label="Team Number"
                        type="number"
                        value={formData.team_number}
                        onChange={(e) => handleChange('team_number', Math.max(0, parseInt(e.target.value, 10)))}
                        inputProps={{ min: 0 }}
                        disabled // Disable the Team Number field
                    />
                </div>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                    {!teamPage && <>
                        <h4 className='text-white mb-0'>Autos</h4>
                        <ImageList cols={1}>
                            {formData.data.autos.map((auto, idx) => {
                                // console.log(auto, idx)
                                return <RenderSelectablePieces auto={auto} idx={idx} />
                            })}
                        </ImageList>
                        <Button variant="contained" onClick={addAuto}>
                            Add an Auto
                        </Button>
                    </>
                    }

                </div>
                <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
                    <h4 className="text-white mb-0">Drive Train</h4>
                    <Autocomplete
                        disablePortal
                        id="Drive Train"
                        options={[{ label: 'Mecanum' }, { label: 'Swerve' }, { label: 'Tank' }]}
                        renderInput={(params) => <TextField {...params} label="Drive Train" onChange={(e, value) => { handleChange('data.drive_train', e.target.value) }} />}
                        freeSolo={true}
                        value={formData.data.drive_train}
                        onChange={(e, value) => { handleChange('data.drive_train', value?.label) }}
                        disabled={teamPage}
                    />
                    <h4 className="text-white mb-0">Scores in Amp?</h4>
                    <Switch
                        label="Scores in Amp?"
                        checked={formData.data.amp_scoring}
                        onChange={(e) => handleChange('data.amp_scoring', e.target.checked)}
                        disabled={teamPage}
                    />
                    <h4 className="text-white mb-0">Scores in Speaker?</h4>
                    <Switch
                        label="Scores in Speaker?"
                        checked={formData.data.speaker_scoring}
                        onChange={(e) => handleChange('data.speaker_scoring', e.target.checked)}
                        disabled={teamPage}
                    />
                    <h4 className="text-white mb-0">Scores in Trap?</h4>
                    <Switch
                        label="Scores in Trap?"
                        checked={formData.data.trap_scoring}
                        onChange={(e) => handleChange('data.trap_scoring', e.target.checked)}
                        disabled={teamPage}
                    />
                    <h4 className="text-white mb-0">Can Climb?</h4>
                    <Switch
                        label="Can Climb?"
                        checked={formData.data.can_climb}
                        onChange={(e) => handleChange('data.can_climb', e.target.checked)}
                        disabled={teamPage}
                    />
                    <h4 className="text-white mb-0">Can Harmonize?</h4>
                    <Switch
                        label="Can Harmonize?"
                        checked={formData.data.can_harmonize}
                        onChange={(e) => handleChange('data.can_harmonize', e.target.checked)}
                        disabled={teamPage}
                    />
                    <h4 className="text-white mb-0">Can Fit Under Stage?</h4>
                    <Switch
                        label="Can Fit Under Stage?"
                        checked={formData.data.go_under_stage}
                        onChange={(e) => handleChange('data.go_under_stage', e.target.checked)}
                        disabled={teamPage}
                    />
                    <h4 className="text-white mb-0">Has Ground Pickup?</h4>
                    <Switch
                        label="Ground Pickup?"
                        checked={formData.data.ground_pick_up}
                        onChange={(e) => handleChange('data.ground_pick_up', e.target.checked)}
                        disabled={teamPage}
                    />
                    <h4 className="text-white mb-0">Has Feeder Station Pickup?</h4>
                    <Switch
                        label="Feeder Station Pickup?"
                        checked={formData.data.feeder_pick_up}
                        onChange={(e) => handleChange('data.feeder_pick_up', e.target.checked)}
                        disabled={teamPage}
                    />
                    <Autocomplete
                        disablePortal
                        id="Favorite Color"
                        options={[
                            { "label": "AliceBlue" },
                            { "label": "AntiqueWhite" },
                            { "label": "Aqua" },
                            { "label": "Aquamarine" },
                            { "label": "Azure" },
                            { "label": "Beige" },
                            { "label": "Bisque" },
                            { "label": "Black" },
                            { "label": "BlanchedAlmond" },
                            { "label": "Blue" },
                            { "label": "BlueViolet" },
                            { "label": "Brown" },
                            { "label": "BurlyWood" },
                            { "label": "CadetBlue" },
                            { "label": "Chartreuse" },
                            { "label": "Chocolate" },
                            { "label": "Coral" },
                            { "label": "CornflowerBlue" },
                            { "label": "Cornsilk" },
                            { "label": "Crimson" },
                            { "label": "Cyan" },
                            { "label": "DarkBlue" },
                            { "label": "DarkCyan" },
                            { "label": "DarkGoldenRod" },
                            { "label": "DarkGray" },
                            { "label": "DarkGreen" },
                            { "label": "DarkKhaki" },
                            { "label": "DarkMagenta" },
                            { "label": "DarkOliveGreen" },
                            { "label": "DarkOrange" },
                            { "label": "DarkOrchid" },
                            { "label": "DarkRed" },
                            { "label": "DarkSalmon" },
                            { "label": "DarkSeaGreen" },
                            { "label": "DarkSlateBlue" },
                            { "label": "DarkSlateGray" },
                            { "label": "DarkTurquoise" },
                            { "label": "DarkViolet" },
                            { "label": "DeepPink" },
                            { "label": "DeepSkyBlue" },
                            { "label": "DimGray" },
                            { "label": "DodgerBlue" },
                            { "label": "FireBrick" },
                            { "label": "FloralWhite" },
                            { "label": "ForestGreen" },
                            { "label": "Fuchsia" },
                            { "label": "Gainsboro" },
                            { "label": "GhostWhite" },
                            { "label": "Gold" },
                            { "label": "GoldenRod" },
                            { "label": "Gray" },
                            { "label": "Green" },
                            { "label": "GreenYellow" },
                            { "label": "HoneyDew" },
                            { "label": "HotPink" },
                            { "label": "IndianRed" },
                            { "label": "Indigo" },
                            { "label": "Ivory" },
                            { "label": "Khaki" },
                            { "label": "Lavender" },
                            { "label": "LavenderBlush" },
                            { "label": "LawnGreen" },
                            { "label": "LemonChiffon" },
                            { "label": "LightBlue" },
                            { "label": "LightCoral" },
                            { "label": "LightCyan" },
                            { "label": "LightGoldenRodYellow" },
                            { "label": "LightGray" },
                            { "label": "LightGreen" },
                            { "label": "LightPink" },
                            { "label": "LightSalmon" },
                            { "label": "LightSeaGreen" },
                            { "label": "LightSkyBlue" },
                            { "label": "LightSlateGray" },
                            { "label": "LightSteelBlue" },
                            { "label": "LightYellow" },
                            { "label": "Lime" },
                            { "label": "LimeGreen" },
                            { "label": "Linen" },
                            { "label": "Magenta" },
                            { "label": "Maroon" },
                            { "label": "MediumAquaMarine" },
                            { "label": "MediumBlue" },
                            { "label": "MediumOrchid" },
                            { "label": "MediumPurple" },
                            { "label": "MediumSeaGreen" },
                            { "label": "MediumSlateBlue" },
                            { "label": "MediumSpringGreen" },
                            { "label": "MediumTurquoise" },
                            { "label": "MediumVioletRed" },
                            { "label": "MidnightBlue" },
                            { "label": "MintCream" },
                            { "label": "MistyRose" },
                            { "label": "Moccasin" },
                            { "label": "NavajoWhite" },
                            { "label": "Navy" },
                            { "label": "OldLace" },
                            { "label": "Olive" },
                            { "label": "OliveDrab" },
                            { "label": "Orange" },
                            { "label": "OrangeRed" },
                            { "label": "Orchid" },
                            { "label": "PaleGoldenRod" },
                            { "label": "PaleGreen" },
                            { "label": "PaleTurquoise" },
                            { "label": "PaleVioletRed" },
                            { "label": "PapayaWhip" },
                            { "label": "PeachPuff" },
                            { "label": "Peru" },
                            { "label": "Pink" },
                            { "label": "Plum" },
                            { "label": "PowderBlue" },
                            { "label": "Purple" },
                            { "label": "RebeccaPurple" },
                            { "label": "Red" },
                            { "label": "RosyBrown" },
                            { "label": "RoyalBlue" },
                            { "label": "SaddleBrown" },
                            { "label": "Salmon" },
                            { "label": "SandyBrown" },
                            { "label": "SeaGreen" },
                            { "label": "SeaShell" },
                            { "label": "Sienna" },
                            { "label": "Silver" },
                            { "label": "SkyBlue" },
                            { "label": "SlateBlue" },
                            { "label": "SlateGray" },
                            { "label": "Snow" },
                            { "label": "SpringGreen" },
                            { "label": "SteelBlue" },
                            { "label": "Tan" },
                            { "label": "Teal" },
                            { "label": "Thistle" },
                            { "label": "Tomato" },
                            { "label": "Turquoise" },
                            { "label": "Violet" },
                            { "label": "Wheat" },
                            { "label": "White" },
                            { "label": "WhiteSmoke" },
                            { "label": "Yellow" },
                            { "label": "YellowGreen" }
                        ]
                        }
                        renderInput={(params) => <TextField {...params} label="Favorite Color" onChange={(e, value) => { handleChange('data.favorite_color', e.target.value) }} />}
                        freeSolo={true}
                        value={formData.data.favorite_color}
                        onChange={(e, value) => handleChange('data.favorite_color', value?.label)}
                        disabled={teamPage}
                    />
                </div>
                {!teamPage ?
                    <Button variant="contained" onClick={handleSubmit}>
                        Submit
                    </Button> : <>
                        <h4 className='text-white mb-0'>Autos</h4>
                        {formData.data.autos.length === 0 && <h5 className='text-white mb-0'>No Auto Data</h5>}
                        <ImageList cols={3}>
                            {formData.data.autos.map((auto, idx) => {
                                return <RenderSelectablePieces auto={auto} idx={idx} />
                            })}
                        </ImageList >
                    </>
                }
            </form>}
            {(!showForm) &&
                <div style={{ display: 'flex', flexDirection: 'column', gap: '16px', padding: '16px' }}>
                    <h1 className="text-white mb-0">{text}</h1>
                    <Button variant="contained" color="primary" onClick={backToScouting}>
                        Back To Scouting
                    </Button>
                    <Button variant="contained" color="primary" onClick={changeData}>
                        Change Data
                    </Button>
                </div>
            }
        </Card>
    </>
    );
};

export default PitScoutingForm;