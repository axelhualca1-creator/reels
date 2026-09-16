import React from "react";
import {
  AbsoluteFill,
  getStaticFiles,
  interpolate,
  OffthreadVideo,
  spring,
  staticFile,
  useCurrentFrame,
  useVideoConfig,
} from "remotion";
import { loadFonts } from "./fonts";

const { fontFamily } = loadFonts();

const AWARDS_VIDEO = staticFile("videos/awards-reveal.mp4");

const awardsVideoExists = () =>
  getStaticFiles().some((f) => f.src === AWARDS_VIDEO);

export const AuthorScene: React.FC<{ authorName: string; brokerage: string }> = ({
  authorName,
  brokerage,
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const hasAwardsVideo = awardsVideoExists();

  const quoteProgress = spring({ frame, fps, config: { damping: 200 } });
  const lineWidth = interpolate(quoteProgress, [0, 1], [0, 90]);
  const quoteOpacity = interpolate(frame, [0, 18], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  const byProgress = spring({ frame: frame - 40, fps, config: { damping: 200 } });

  return (
    <AbsoluteFill
      style={{
        backgroundColor: "#0c0906",
        justifyContent: "center",
        alignItems: "center",
        padding: "0 90px",
        textAlign: "center",
      }}
    >
      {hasAwardsVideo ? (
        <>
          <AbsoluteFill>
            <OffthreadVideo src={AWARDS_VIDEO} volume={0} style={{ objectFit: "cover" }} />
          </AbsoluteFill>
          <AbsoluteFill
            style={{
              background:
                "linear-gradient(to top, rgba(6,4,2,0.88) 0%, rgba(6,4,2,0.55) 45%, rgba(6,4,2,0.35) 100%)",
            }}
          />
        </>
      ) : null}
      <div
        style={{
          height: 2,
          width: lineWidth,
          background: "linear-gradient(90deg, transparent, #d4af6a, transparent)",
          marginBottom: 30,
        }}
      />
      <div
        style={{
          fontFamily,
          fontStyle: "italic",
          fontWeight: 600,
          fontSize: 36,
          lineHeight: 1.35,
          color: "#f5ead3",
          opacity: quoteOpacity,
        }}
      >
        &ldquo;La confianza no se gana prometiendo resultados rápidos; se gana
        demostrando orden, criterio y responsabilidad.&rdquo;
      </div>
      <div
        style={{
          height: 2,
          width: lineWidth,
          background: "linear-gradient(90deg, transparent, #d4af6a, transparent)",
          margin: "30px 0 46px",
        }}
      />
      <div
        style={{
          opacity: interpolate(byProgress, [0, 1], [0, 1]),
          transform: `translateY(${interpolate(byProgress, [0, 1], [14, 0])}px)`,
        }}
      >
        <div
          style={{
            fontFamily,
            fontWeight: 700,
            fontSize: 28,
            color: "#f5ead3",
            letterSpacing: 1,
          }}
        >
          {authorName}
        </div>
        <div
          style={{
            fontFamily,
            fontSize: 20,
            color: "#d4af6a",
            letterSpacing: 3,
            textTransform: "uppercase",
            marginTop: 8,
          }}
        >
          {brokerage}
        </div>
      </div>
    </AbsoluteFill>
  );
};
