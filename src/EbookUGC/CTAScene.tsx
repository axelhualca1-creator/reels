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

export const CTAScene: React.FC<{ authorName: string; contact?: string }> = ({
  authorName,
  contact,
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const coverProgress = spring({ frame, fps, config: { damping: 200 } });
  const coverScale = interpolate(coverProgress, [0, 1], [0.42, 0.46]);
  const coverOpacity = interpolate(frame, [0, 12], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  const ctaProgress = spring({ frame: frame - 22, fps, config: { damping: 200 } });

  const swipeCycle = frame % 36;
  const swipeProgress = interpolate(swipeCycle, [0, 36], [0, 1]);
  const swipeY = interpolate(swipeProgress, [0, 1], [14, -18]);
  const swipeOpacity = interpolate(swipeProgress, [0, 0.15, 0.8, 1], [0, 1, 1, 0]);

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
            "radial-gradient(ellipse at center, rgba(212,175,106,0.2) 0%, rgba(0,0,0,0) 60%)",
        }}
      />
      <Sequence from={2} durationInFrames={20}>
        <Audio src={staticFile("audio/pop.mp3")} volume={0.6} />
      </Sequence>
      <div
        style={{
          opacity: coverOpacity,
          transform: `scale(${coverScale})`,
          marginBottom: -40,
        }}
      >
        <BookCover authorName={authorName} />
      </div>
      <div
        style={{
          opacity: interpolate(ctaProgress, [0, 1], [0, 1]),
          transform: `translateY(${interpolate(ctaProgress, [0, 1], [18, 0])}px)`,
          textAlign: "center",
          marginTop: 30,
        }}
      >
        <div
          style={{
            fontFamily,
            fontWeight: 700,
            fontSize: 46,
            color: "#f5ead3",
            letterSpacing: 1,
          }}
        >
          Consíguelo hoy
        </div>
        <div
          style={{
            fontFamily,
            fontSize: 22,
            color: "#d4af6a",
            marginTop: 14,
            letterSpacing: 1,
          }}
        >
          Escríbeme y te lo envío
        </div>
        {contact ? (
          <div
            style={{
              fontFamily,
              fontSize: 22,
              color: "#f5ead3",
              marginTop: 10,
              letterSpacing: 2,
            }}
          >
            {contact}
          </div>
        ) : null}
        <div
          style={{
            marginTop: 40,
            display: "flex",
            flexDirection: "column",
            alignItems: "center",
          }}
        >
          <div
            style={{
              fontFamily,
              fontWeight: 700,
              fontSize: 30,
              color: "#f5ead3",
              opacity: swipeOpacity,
              transform: `translateY(${swipeY}px)`,
            }}
          >
            ↑
          </div>
          <div
            style={{
              fontFamily,
              fontWeight: 700,
              fontSize: 26,
              color: "#d4af6a",
              letterSpacing: 1,
              textTransform: "uppercase",
              marginTop: 4,
            }}
          >
            Desliza hacia arriba para comprar
          </div>
        </div>
      </div>
    </AbsoluteFill>
  );
};
