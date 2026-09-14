import React from "react";
import {
  AbsoluteFill,
  Img,
  interpolate,
  spring,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { loadFonts } from "./fonts";

const { fontFamily } = loadFonts();

export const ClosingCard: React.FC<{
  durationInFrames: number;
  location: string;
  agentName: string;
  brokerage: string;
  contact?: string;
}> = ({ durationInFrames, location, agentName, brokerage, contact }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const textIn = spring({ frame: frame - 6, fps, config: { damping: 200 } });
  const lineWidth = interpolate(textIn, [0, 1], [0, 120]);
  const textOpacity = interpolate(frame, [6, 20], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const textShift = interpolate(frame, [6, 20], [16, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  const darken = interpolate(frame, [0, durationInFrames], [0.65, 0.8], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill style={{ backgroundColor: "#000" }}>
      <Img
        src={staticFile("fotos/facade.jpg")}
        style={{
          width: "100%",
          height: "100%",
          objectFit: "cover",
          objectPosition: "center 65%",
          filter:
            "brightness(0.45) contrast(1.3) saturate(0.9) sepia(0.1) hue-rotate(4deg)",
        }}
      />
      <AbsoluteFill
        style={{
          background: `linear-gradient(to top, rgba(0,0,0,${darken}) 0%, rgba(10,8,4,0.25) 45%, rgba(20,20,30,0.35) 100%)`,
        }}
      />
      <AbsoluteFill
        style={{
          justifyContent: "flex-end",
          alignItems: "center",
          paddingBottom: 190,
          opacity: textOpacity,
          transform: `translateY(${textShift}px)`,
        }}
      >
        <div
          style={{
            height: 2,
            width: lineWidth,
            background: "linear-gradient(90deg, transparent, #d4af6a, transparent)",
            marginBottom: 22,
          }}
        />
        <div
          style={{
            fontFamily,
            fontSize: 52,
            color: "#f5ead3",
            letterSpacing: 6,
            textTransform: "uppercase",
            textAlign: "center",
          }}
        >
          {location}
        </div>
        <div
          style={{
            fontFamily,
            fontSize: 30,
            color: "#e7d9b8",
            letterSpacing: 1,
            marginTop: 14,
            textAlign: "center",
          }}
        >
          {agentName}
        </div>
        <div
          style={{
            fontFamily,
            fontSize: 24,
            color: "#d4af6a",
            letterSpacing: 3,
            textTransform: "uppercase",
            marginTop: 6,
            textAlign: "center",
          }}
        >
          {brokerage}
        </div>
        {contact ? (
          <div
            style={{
              fontFamily,
              fontSize: 22,
              color: "#f5ead3",
              letterSpacing: 2,
              marginTop: 16,
              textAlign: "center",
            }}
          >
            {contact}
          </div>
        ) : null}
        <div
          style={{
            height: 2,
            width: lineWidth,
            background: "linear-gradient(90deg, transparent, #d4af6a, transparent)",
            marginTop: 22,
          }}
        />
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
