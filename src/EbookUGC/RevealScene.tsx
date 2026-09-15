import React from "react";
import {
  AbsoluteFill,
  Audio,
  interpolate,
  Sequence,
  spring,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { BookCover } from "./BookCover";
import { loadFonts } from "./fonts";

const { fontFamily } = loadFonts();

export const RevealScene: React.FC<{ authorName: string }> = ({ authorName }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const pop = spring({ frame, fps, config: { damping: 14, mass: 0.6 } });
  const scale = interpolate(pop, [0, 1], [0.7, 1]);
  const rotate = interpolate(pop, [0, 1], [-6, -3]);
  const opacity = interpolate(frame, [0, 12], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  const tagProgress = spring({ frame: frame - 24, fps, config: { damping: 200 } });

  return (
    <AbsoluteFill
      style={{
        backgroundColor: "#0c0906",
        justifyContent: "center",
        alignItems: "center",
      }}
    >
      <AbsoluteFill
        style={{
          background:
            "radial-gradient(ellipse at center, rgba(212,175,106,0.18) 0%, rgba(0,0,0,0) 65%)",
        }}
      />
      <Sequence from={2} durationInFrames={20}>
        <Audio src={staticFile("audio/pop.mp3")} volume={0.8} />
      </Sequence>
      <div
        style={{
          opacity,
          transform: `scale(${scale * 0.62}) rotate(${rotate}deg)`,
        }}
      >
        <BookCover authorName={authorName} />
      </div>
      <div
        style={{
          position: "absolute",
          bottom: 210,
          fontFamily,
          fontWeight: 700,
          fontSize: 32,
          color: "#f5ead3",
          letterSpacing: 1,
          opacity: interpolate(tagProgress, [0, 1], [0, 1]),
          transform: `translateY(${interpolate(tagProgress, [0, 1], [16, 0])}px)`,
        }}
      >
        Este es el kit que necesitabas.
      </div>
    </AbsoluteFill>
  );
};
