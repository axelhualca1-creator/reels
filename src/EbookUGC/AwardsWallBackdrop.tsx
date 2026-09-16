import React from "react";
import { AbsoluteFill, interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { loadFonts } from "./fonts";
import { TrophyIcon } from "./TrophyIcon";

const { fontFamily } = loadFonts();

const Badge: React.FC<{
  text: string;
  top?: number | string;
  bottom?: number | string;
  left?: number | string;
  right?: number | string;
  delay: number;
  rotate?: number;
}> = ({ text, top, bottom, left, right, delay, rotate = 0 }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const progress = spring({ frame: frame - delay, fps, config: { damping: 200 } });

  return (
    <div
      style={{
        position: "absolute",
        top,
        bottom,
        left,
        right,
        opacity: interpolate(progress, [0, 1], [0, 0.9]),
        transform: `translateX(-50%) rotate(${rotate}deg) scale(${interpolate(progress, [0, 1], [0.8, 1])})`,
        fontFamily,
        fontWeight: 700,
        fontSize: 15,
        letterSpacing: 2,
        color: "#d4af6a",
        textTransform: "uppercase",
        border: "1px solid rgba(212,175,106,0.55)",
        borderRadius: 6,
        padding: "8px 14px",
        whiteSpace: "nowrap",
      }}
    >
      {text}
    </div>
  );
};

const Piece: React.FC<{
  size: number;
  top?: number | string;
  bottom?: number | string;
  left?: number | string;
  right?: number | string;
  delay: number;
  rotate?: number;
  opacity?: number;
}> = ({ size, top, bottom, left, right, delay, rotate = 0, opacity = 0.85 }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const progress = spring({ frame: frame - delay, fps, config: { damping: 200 } });

  return (
    <div
      style={{
        position: "absolute",
        top,
        bottom,
        left,
        right,
        opacity: interpolate(progress, [0, 1], [0, opacity]),
        transform: `rotate(${rotate}deg) scale(${interpolate(progress, [0, 1], [0.6, 1])})`,
      }}
    >
      <TrophyIcon size={size} />
    </div>
  );
};

export const AwardsWallBackdrop: React.FC = () => {
  const frame = useCurrentFrame();
  const { durationInFrames } = useVideoConfig();

  const zoom = interpolate(frame, [0, durationInFrames], [1.16, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  const heroProgress = spring({ frame, fps: 30, config: { damping: 15, mass: 0.7 } });

  return (
    <AbsoluteFill style={{ overflow: "hidden" }}>
      <AbsoluteFill
        style={{
          transform: `scale(${zoom})`,
        }}
      >
        <AbsoluteFill
          style={{
            background:
              "radial-gradient(ellipse at 50% 14%, rgba(212,175,106,0.22) 0%, rgba(0,0,0,0) 55%)",
          }}
        />

        {/* Hero trophy, top center */}
        <div
          style={{
            position: "absolute",
            top: "6%",
            left: "50%",
            transform: `translateX(-50%) scale(${interpolate(heroProgress, [0, 1], [0.5, 1])})`,
            opacity: interpolate(heroProgress, [0, 1], [0, 1]),
          }}
        >
          <TrophyIcon size={150} />
        </div>

        <Piece size={64} top="4%" left="8%" delay={10} rotate={-14} />
        <Piece size={54} top="8%" right="9%" delay={16} rotate={11} />
        <Piece size={58} bottom="10%" left="10%" delay={22} rotate={9} />
        <Piece size={66} bottom="6%" right="7%" delay={14} rotate={-9} />

        <Badge text="Agente reconocida" top="20%" left="50%" delay={28} rotate={-2} />
        <Badge text="RE/MAX Golden Home" bottom="18%" left="50%" delay={34} rotate={2} />
      </AbsoluteFill>
    </AbsoluteFill>
  );
};
