import { Star, ShieldCheck, TrendingUp, BadgeCheck, Clock3 } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { ScrollArea } from "@/components/ui/scroll-area";
import { getAgentPublicProfile } from "@/lib/agent-profiles";

type AgentPublicProfileDialogProps = {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  agent: {
    name: string;
    image: string;
    verified: boolean;
  };
};

const currencyFormatter = new Intl.NumberFormat("en-NG", {
  style: "currency",
  currency: "NGN",
  maximumFractionDigits: 0,
});

function RatingStars({ value }: { value: number }) {
  const rounded = Math.round(value);
  return (
    <div className="flex items-center gap-1">
      {Array.from({ length: 5 }).map((_, index) => (
        <Star
          key={index}
          className={`h-4 w-4 ${index < rounded ? "fill-amber-400 text-amber-400" : "text-slate-300"}`}
        />
      ))}
    </div>
  );
}

export function AgentPublicProfileDialog({ open, onOpenChange, agent }: AgentPublicProfileDialogProps) {
  const profile = getAgentPublicProfile(agent);

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-3xl max-h-[85vh] overflow-hidden">
        <DialogHeader>
          <DialogTitle>Agent Public Profile</DialogTitle>
        </DialogHeader>

        <ScrollArea className="max-h-[72vh] pr-3">
          <div className="space-y-6">
            <div className="rounded-2xl border border-slate-200 bg-slate-50 p-4">
              <div className="flex items-center gap-4">
                <img
                  src={profile.image}
                  alt={profile.name}
                  className="h-16 w-16 rounded-xl object-cover ring-2 ring-white"
                />
                <div className="space-y-1">
                  <div className="flex items-center gap-2">
                    <h3 className="text-lg font-bold text-slate-900">{profile.name}</h3>
                    {profile.verified && (
                      <Badge className="bg-blue-100 text-blue-700 border-blue-200">
                        <ShieldCheck className="h-3.5 w-3.5 mr-1" />
                        Verified Agent
                      </Badge>
                    )}
                  </div>
                  <p className="text-sm text-slate-500">
                    Public performance profile. Contact information is intentionally hidden.
                  </p>
                </div>
              </div>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-3">
              <Card>
                <CardHeader className="pb-2">
                  <CardTitle className="text-sm text-slate-500">Sales Rating</CardTitle>
                </CardHeader>
                <CardContent className="space-y-1">
                  <div className="text-2xl font-bold text-slate-900">{profile.salesRating.toFixed(1)}</div>
                  <RatingStars value={profile.salesRating} />
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="pb-2">
                  <CardTitle className="text-sm text-slate-500">Reviews</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="flex items-center gap-2">
                    <BadgeCheck className="h-5 w-5 text-green-600" />
                    <span className="text-2xl font-bold text-slate-900">{profile.totalReviews}</span>
                  </div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="pb-2">
                  <CardTitle className="text-sm text-slate-500">Closed Deals</CardTitle>
                </CardHeader>
                <CardContent>
                  <div className="flex items-center gap-2">
                    <TrendingUp className="h-5 w-5 text-blue-600" />
                    <span className="text-2xl font-bold text-slate-900">{profile.totalClosedDeals}</span>
                  </div>
                </CardContent>
              </Card>
            </div>

            <Card>
              <CardHeader>
                <CardTitle className="text-base">Recent Deals</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                {profile.recentDeals.map((deal) => (
                  <div key={deal.id} className="rounded-lg border border-slate-200 p-3">
                    <p className="font-semibold text-slate-900">{deal.title}</p>
                    <p className="text-sm text-slate-500">{deal.location}</p>
                    <p className="text-sm font-medium text-slate-800 mt-1">
                      Listed at {currencyFormatter.format(deal.price)}
                    </p>
                  </div>
                ))}
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-base">Closed Deals</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                {profile.closedDeals.map((deal) => (
                  <div key={deal.id} className="rounded-lg border border-slate-200 p-3">
                    <div className="flex items-start justify-between gap-2">
                      <div>
                        <p className="font-semibold text-slate-900">{deal.title}</p>
                        <p className="text-sm text-slate-500">{deal.location}</p>
                      </div>
                      <Badge className="bg-green-100 text-green-700 border-green-200">Closed</Badge>
                    </div>
                    <div className="mt-2 flex items-center justify-between text-sm">
                      <span className="font-medium text-slate-800">
                        {currencyFormatter.format(deal.closedValue)}
                      </span>
                      <span className="inline-flex items-center gap-1 text-slate-500">
                        <Clock3 className="h-3.5 w-3.5" />
                        {deal.closedAt}
                      </span>
                    </div>
                  </div>
                ))}
              </CardContent>
            </Card>

            <Card>
              <CardHeader>
                <CardTitle className="text-base">Latest Reviews</CardTitle>
              </CardHeader>
              <CardContent className="space-y-3">
                {profile.reviews.map((review) => (
                  <div key={review.id} className="rounded-lg border border-slate-200 p-3">
                    <div className="flex items-center justify-between">
                      <p className="font-semibold text-slate-900">{review.reviewer}</p>
                      <span className="text-xs text-slate-500">{review.date}</span>
                    </div>
                    <div className="mt-1 flex items-center gap-2">
                      <RatingStars value={review.rating} />
                      <span className="text-sm font-medium text-slate-700">{review.rating.toFixed(1)}</span>
                    </div>
                    <p className="text-sm text-slate-600 mt-2">{review.comment}</p>
                  </div>
                ))}
              </CardContent>
            </Card>
          </div>
        </ScrollArea>
      </DialogContent>
    </Dialog>
  );
}
