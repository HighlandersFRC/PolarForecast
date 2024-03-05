import React, { useEffect, useRef, useState } from 'react';

const AutoDisplay = ({ scoutingData }) => {
    const url = new URL(window.location.href);
    const serverPath = url.pathname.split("/")[0];
    const [fieldImageWidth, setFieldImageWidth] = useState(0);
    const [imageScaleFactor, setImageScaleFactor] = useState(1);
    const [imageLoaded, setImageLoaded] = useState(false)
    const fieldImageRef = useRef(null);

    useEffect(() => {
        if (fieldImageRef.current) {
            const { naturalWidth, offsetWidth } = fieldImageRef.current;
            setFieldImageWidth(offsetWidth);
            setImageScaleFactor(offsetWidth / naturalWidth);
        }
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
            <p className="text-white mb-0">Team: {scoutingData.team_number}  |  Match: {scoutingData.match_number}  |  Scout: {scoutingData.scout_info.name}  |  Amp: {scoutingData.data.auto.amp} | Speaker: {scoutingData.data.auto.speaker}</p>
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
                        width: `${60 * imageScaleFactor}px`,
                        height: `${60 * imageScaleFactor}px`,
                        filter: scoutingData.data.selectedPieces.includes('spike_left') ? 'none' : 'grayscale(100%)'
                    }}
                />
                <img
                    src="/Note.png"
                    style={{
                        position: 'absolute',
                        ...calculatePosition(433, 978),
                        width: `${60 * imageScaleFactor}px`,
                        height: `${60 * imageScaleFactor}px`,
                        filter: scoutingData.data.selectedPieces.includes('spike_middle') ? 'none' : 'grayscale(100%)'
                    }}
                />
                <img
                    src="/Note.png"
                    style={{
                        position: 'absolute',
                        ...calculatePosition(679, 978),
                        width: `${60 * imageScaleFactor}px`,
                        height: `${60 * imageScaleFactor}px`,
                        filter: scoutingData.data.selectedPieces.includes('spike_right') ? 'none' : 'grayscale(100%)'
                    }}
                />
                <img
                    src="/Note.png"
                    style={{
                        position: 'absolute',
                        ...calculatePosition(108, 61),
                        width: `${60 * imageScaleFactor}px`,
                        height: `${60 * imageScaleFactor}px`,
                        filter: scoutingData.data.selectedPieces.includes('halfway_far_left') ? 'none' : 'grayscale(100%)'
                    }}
                />
                <img
                    src="/Note.png"
                    style={{
                        position: 'absolute',
                        ...calculatePosition(394, 61),
                        width: `${60 * imageScaleFactor}px`,
                        height: `${60 * imageScaleFactor}px`,
                        filter: scoutingData.data.selectedPieces.includes('halfway_middle_left') ? 'none' : 'grayscale(100%)'
                    }}
                />
                <img
                    src="/Note.png"
                    style={{
                        position: 'absolute',
                        ...calculatePosition(679, 61),
                        width: `${60 * imageScaleFactor}px`,
                        height: `${60 * imageScaleFactor}px`,
                        filter: scoutingData.data.selectedPieces.includes('halfway_middle') ? 'none' : 'grayscale(100%)'
                    }}
                />
                <img
                    src="/Note.png"
                    style={{
                        position: 'absolute',
                        ...calculatePosition(965, 61),
                        width: `${60 * imageScaleFactor}px`,
                        height: `${60 * imageScaleFactor}px`,
                        filter: scoutingData.data.selectedPieces.includes('halfway_middle_right') ? 'none' : 'grayscale(100%)'
                    }}
                />
                <img
                    src="/Note.png"
                    style={{
                        position: 'absolute',
                        ...calculatePosition(1251, 61),
                        width: `${60 * imageScaleFactor}px`,
                        height: `${60 * imageScaleFactor}px`,
                        filter: scoutingData.data.selectedPieces.includes('halfway_far_right') ? 'none' : 'grayscale(100%)'
                    }}
                />
            </div>
        </div>
    );
};

export default AutoDisplay;
