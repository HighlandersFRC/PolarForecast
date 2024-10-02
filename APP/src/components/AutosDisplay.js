import React, { useEffect, useRef, useState } from 'react';
import { ImageListItemBar, ImageListItem } from '@mui/material';

const AutoDisplay = ({ scoutingData }) => {
    const url = new URL(window.location.href);
    const params = url.pathname.split("/")
    const serverPath = url.pathname.split("/")[0];
    const [fieldImageWidth, setFieldImageWidth] = useState(0);
    const [imageScaleFactor, setImageScaleFactor] = useState(1);
    const [imageLoaded, setImageLoaded] = useState(false)
    const fieldImageRef = useRef(null);
    const NOTE_SIZE = 200;

    useEffect(() => {
        if (fieldImageRef.current) {
            const { naturalWidth, offsetWidth } = fieldImageRef.current;
            setFieldImageWidth(offsetWidth);
            setImageScaleFactor(offsetWidth / naturalWidth);
        }
        console.log(params[5]?.split("-")[0])
    }, [imageLoaded]);

    const calculatePosition = (x, y) => {
        const scaledX = x * imageScaleFactor;
        const scaledY = y * imageScaleFactor;
        return { left: `${scaledX}px`, top: `${scaledY}px` };
    };

    const handleImageLoad = () => {
        setImageLoaded(true);
    };

    const pieces = ['spike_left', 'spike_middle', 'spike_right', 'halfway_far_left', 'halfway_middle_left', 'halfway_middle', 'halfway_middle_right', 'halfway_far_right'];
    const pieceX = [186, 433, 679, 70, 355, 640, 925, 1210]
    const pieceY = [850, 850, 850, 61, 61, 61, 61, 61]

    return (
        <ImageListItem style={{ display: "flex", flexDirection: "column" }}>
            <>
                <div style={{ position: 'relative', maxWidth: '100%', height: 'auto' }}>
                    {/* Display your field image here */}
                    <img
                        ref={fieldImageRef}
                        src={serverPath + "/BlankAutoField.png"}
                        alt="Field"
                        style={{ maxWidth: '100%', height: 'auto' }}
                        onLoad={handleImageLoad}
                    />
                    {pieces.map((piece, idx) => {
                        return (
                            <div
                                key={piece}
                                style={{
                                    position: 'absolute',
                                    ...calculatePosition(pieceX[idx], pieceY[idx]),
                                    width: `${NOTE_SIZE * imageScaleFactor}px`,
                                    height: `${NOTE_SIZE * imageScaleFactor}px`,
                                    filter: scoutingData.data.selectedPieces.includes(piece) ? 'none' : 'grayscale(100%)',
                                }}
                            >
                                <img src="/Note.png" alt={`Note ${piece}`} style={{ width: '100%', height: '100%' }} />
                                <span style={{ position: 'absolute', top: '50%', left: '50%', transform: 'translate(-50%, -50%)', color: 'white', fontSize: `${100 * imageScaleFactor}px`, fontWeight: 'bold' }}>
                                    {scoutingData.data.selectedPieces.indexOf(piece) === -1 ? "" : scoutingData.data.selectedPieces.indexOf(piece) + 1}
                                </span>
                            </div>
                        )
                    })}
                </div>
            </>
            <ImageListItemBar position="below" title={(params.length == 5 ? `Team: ${scoutingData.team_number} | ` : "") + "Match:" + scoutingData.match_number + " | " + (params.length == 6 && params[5]?.split("-")[0] == "team" ? `Scout: ${scoutingData.scout_info.name} | ` : "") + "Scored:" + (scoutingData.data.auto.amp + scoutingData.data.auto.speaker)} />
        </ImageListItem>
    );
};

export default AutoDisplay;
