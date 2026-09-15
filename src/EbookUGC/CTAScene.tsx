import React from "react";
import { AbsoluteFill, interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
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
  const bounce = interpolate(frame % 50, [0, 25, 50], [0, -10, 0]);

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
            fontFamily,
            fontSize: 24,
            color: "#d4af6a",
            marginTop: 34,
            transform: `translateY(${bounce}px)`,
          }}
        >
          ↑ Link en la bio
        </div>
      </div>
    </AbsoluteFill>
  );
};
