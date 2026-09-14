import "./index.css";
import { Composition, staticFile } from "remotion";
import {
  CaptionedVideo,
  calculateCaptionedVideoMetadata,
  captionedVideoSchema,
} from "./CaptionedVideo";
import {
  PropertyReel,
  propertyReelDurationInFrames,
  propertyReelSchema,
} from "./PropertyReel";
import {
  CinematicTour,
  cinematicTourDurationInFrames,
  cinematicTourSchema,
} from "./CinematicTour";

// Each <Composition> is an entry in the sidebar!

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="CaptionedVideo"
        component={CaptionedVideo}
        calculateMetadata={calculateCaptionedVideoMetadata}
        schema={captionedVideoSchema}
        width={1080}
        height={1920}
        defaultProps={{
          src: staticFile("sample-video.mp4"),
        }}
      />
      <Composition
        id="PropertyReel"
        component={PropertyReel}
        schema={propertyReelSchema}
        width={1080}
        height={1920}
        fps={30}
        durationInFrames={propertyReelDurationInFrames}
        defaultProps={{
          location: "Samborondón",
          agentName: "María Leonor Villegas",
          brokerage: "RE/MAX Golden Home",
          contact: "0993176489",
        }}
      />
      <Composition
        id="CinematicTour"
        component={CinematicTour}
        schema={cinematicTourSchema}
        width={1080}
        height={1920}
        fps={30}
        durationInFrames={cinematicTourDurationInFrames}
        defaultProps={{
          location: "Samborondón",
          agentName: "María Leonor Villegas",
          brokerage: "RE/MAX Golden Home",
          contact: "0993176489",
        }}
      />
    </>
  );
};
