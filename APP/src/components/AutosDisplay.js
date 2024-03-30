import React, { useEffect, useRef, useState } from 'react';

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

    return (
        <div style={{ display: "flex", flexDirection: "column" }}>
            <p className="text-white mb-0">{params.length == 5 ?`Team: ${scoutingData.team_number} |`: ""}  Match: {scoutingData.match_number}  |  {params.length == 6 && params[5]?.split("-")[0] == "team" ? `Scout: ${scoutingData.scout_info.name} |` : ""} Scored: {scoutingData.data.auto.amp+scoutingData.data.auto.speaker}</p>
            <div style={{ position: 'relative', maxWidth: '100%', height: 'auto' }}>
                {/* Display your field image here */}
                <img
                    ref={fieldImageRef}
                    src={serverPath + "/BlankAutoField.png"}
                    alt="Field"
                    style={{ maxWidth: '100%', height: 'auto' }}
                    onLoad={handleImageLoad}
                />
                <img
                    src="/Note.png"
                    style={{
                        position: 'absolute',
                        ...calculatePosition(186, 850),
                        width: `${ NOTE_SIZE * imageScaleFactor}px`,
                        height: `${ NOTE_SIZE * imageScaleFactor}px`,
                        filter: scoutingData.data.selectedPieces.includes('spike_left') ? 'none' : 'grayscale(100%)'
                    }}
                />
                <img
                    src="/Note.png"
                    style={{
                        position: 'absolute',
                        ...calculatePosition(433, 850),
                        width: `${ NOTE_SIZE * imageScaleFactor}px`,
                        height: `${ NOTE_SIZE * imageScaleFactor}px`,
                        filter: scoutingData.data.selectedPieces.includes('spike_middle') ? 'none' : 'grayscale(100%)'
                    }}
                />
                <img
                    src="/Note.png"
                    style={{
                        position: 'absolute',
                        ...calculatePosition(679, 850),
                        width: `${ NOTE_SIZE * imageScaleFactor}px`,
                        height: `${ NOTE_SIZE * imageScaleFactor}px`,
                        filter: scoutingData.data.selectedPieces.includes('spike_right') ? 'none' : 'grayscale(100%)'
                    }}
                />
                <img
                    src="/Note.png"
                    style={{
                        position: 'absolute',
                        ...calculatePosition(70, 61),
                        width: `${ NOTE_SIZE * imageScaleFactor}px`,
                        height: `${ NOTE_SIZE * imageScaleFactor}px`,
                        filter: scoutingData.data.selectedPieces.includes('halfway_far_left') ? 'none' : 'grayscale(100%)'
                    }}
                />
                <img
                    src="/Note.png"
                    style={{
                        position: 'absolute',
                        ...calculatePosition(355, 61),
                        width: `${ NOTE_SIZE * imageScaleFactor}px`,
                        height: `${ NOTE_SIZE * imageScaleFactor}px`,
                        filter: scoutingData.data.selectedPieces.includes('halfway_middle_left') ? 'none' : 'grayscale(100%)'
                    }}
                />
                <img
                    src="/Note.png"
                    style={{
                        position: 'absolute',
                        ...calculatePosition(640, 61),
                        width: `${ NOTE_SIZE * imageScaleFactor}px`,
                        height: `${ NOTE_SIZE * imageScaleFactor}px`,
                        filter: scoutingData.data.selectedPieces.includes('halfway_middle') ? 'none' : 'grayscale(100%)'
                    }}
                />
                <img
                    src="/Note.png"
                    style={{
                        position: 'absolute',
                        ...calculatePosition(925, 61),
                        width: `${ NOTE_SIZE * imageScaleFactor}px`,
                        height: `${ NOTE_SIZE * imageScaleFactor}px`,
                        filter: scoutingData.data.selectedPieces.includes('halfway_middle_right') ? 'none' : 'grayscale(100%)'
                    }}
                />
                <img
                    src="/Note.png"
                    style={{
                        position: 'absolute',
                        ...calculatePosition(1210, 61),
                        width: `${ NOTE_SIZE * imageScaleFactor}px`,
                        height: `${ NOTE_SIZE * imageScaleFactor}px`,
                        filter: scoutingData.data.selectedPieces.includes('halfway_far_right') ? 'none' : 'grayscale(100%)'
                    }}
                />
            </div>
        </div>
    );
};

export default AutoDisplay;
