import { useState } from "react";
import { useLocation } from "wouter";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Calendar as CalendarIcon, Clock, CheckCircle2, User, Users } from "lucide-react";
import { toast } from "@/hooks/use-toast";

export default function ScheduleTourPage() {
  const [, setLocation] = useLocation();
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setSubmitted(true);
    toast({
      title: "Tour Scheduled",
      description: "Our agent will meet you at the property.",
    });
  };

  if (submitted) {
    return (
      <div className="container mx-auto px-4 py-20 text-center max-w-md">
        <div className="w-20 h-20 bg-blue-100 text-blue-600 rounded-full flex items-center justify-center mx-auto mb-6">
          <CheckCircle2 className="w-10 h-10" />
        </div>
        <h2 className="text-2xl font-bold mb-2">Tour Confirmed!</h2>
        <p className="text-slate-500 mb-8">An email with the meeting details has been sent to you.</p>
        <Button onClick={() => setLocation("/")} className="w-full bg-blue-600">Back to Marketplace</Button>
      </div>
    );
  }

  return (
    <div className="container mx-auto px-4 py-12 max-w-3xl">
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <div className="space-y-6">
          <h1 className="text-4xl font-display font-bold text-slate-900 leading-tight">Book a Private <span className="text-blue-600">Property Tour</span></h1>
          <p className="text-lg text-slate-500">See the property in person and get answers to all your questions from a verified Justice City agent.</p>
          
          <div className="space-y-4">
            {[
              { title: "Verified Agent", desc: "Expert guidance during the tour", icon: User },
              { title: "Group Viewings", desc: "Bring family or partners along", icon: Users },
              { title: "On-Site Verification", desc: "Inspect documents on site", icon: CheckCircle2 },
            ].map((feature, i) => (
              <div key={i} className="flex gap-4 p-4 rounded-2xl bg-white border border-slate-100">
                <div className="w-10 h-10 rounded-xl bg-blue-50 text-blue-600 flex items-center justify-center shrink-0">
                  <feature.icon className="w-5 h-5" />
                </div>
                <div>
                  <p className="font-bold text-slate-900">{feature.title}</p>
                  <p className="text-sm text-slate-500">{feature.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>

        <Card className="shadow-xl border-slate-200">
          <CardHeader>
            <CardTitle>Select Date & Time</CardTitle>
            <CardDescription>Pick a slot that works for you.</CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={handleSubmit} className="space-y-6">
              <div className="space-y-2">
                <Label>Pick a Date</Label>
                <div className="grid grid-cols-3 gap-2">
                  {[
                    { day: "Mon", date: "Jan 19" },
                    { day: "Tue", date: "Jan 20" },
                    { day: "Wed", date: "Jan 21" }
                  ].map((d, i) => (
                    <button key={i} type="button" className="p-3 rounded-xl border border-slate-200 text-center hover:border-blue-400 hover:bg-blue-50 transition-all group">
                      <p className="text-xs text-slate-500 group-hover:text-blue-600">{d.day}</p>
                      <p className="font-bold text-slate-900 group-hover:text-blue-700">{d.date}</p>
                    </button>
                  ))}
                </div>
              </div>
              <div className="space-y-2">
                <Label>Pick a Time</Label>
                <div className="grid grid-cols-2 gap-2">
                  {["10:00 AM", "12:00 PM", "2:30 PM", "4:00 PM"].map(time => (
                    <button key={time} type="button" className="p-3 rounded-xl border border-slate-200 text-sm font-medium hover:border-blue-400 hover:bg-blue-50 transition-all">
                      {time}
                    </button>
                  ))}
                </div>
              </div>
              <div className="space-y-2">
                <Label htmlFor="guests">Number of Guests</Label>
                <Input id="guests" type="number" defaultValue={1} min={1} />
              </div>
              <Button type="submit" className="w-full bg-blue-600 hover:bg-blue-700 h-12 text-lg">Confirm Booking</Button>
            </form>
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
